# L17 — Capstone and Cleanup

**Status:** COMPLETED

**Completed:** 2026-10-10

## Objective

Combine application assignment, group membership, Conditional Access,
MFA validation, access removal and cleanup in a controlled identity-only
capstone.

Validate successful Entra sign-in for authorized users, assignment-based
denial for an unassigned user, and denial after temporary group access is
removed. Preserve evidence and restore the application's original
assignment baseline.

## Environment and Scope

- Microsoft Entra ID tenant.
- Microsoft Entra ID P2 licenses assigned to the four available test users.
- Existing Microsoft Entra SAML Toolkit enterprise application from L03.
- Microsoft Entra admin center used for configuration and validation.
- Sign-in logs and audit logs used as evidence.
- No additional Azure infrastructure required.

The capstone used these temporary objects:

| Object | Name |
|---|---|
| Assigned security group | grp-l17-capstone-access |
| Conditional Access policy | CA-L17-Capstone-MFA |

## Test Users

| User | Purpose |
|---|---|
| Ana Maria | Existing authorized user with a direct application assignment |
| Andrei | Temporary user receiving application access through the capstone group |
| Alex | Unassigned negative-control user |
| Claudiu | Available second negative-control user; no screenshot-backed result included |

Administrative and emergency accounts were outside the capstone group.
The captured policy summary shows that exclusions were configured, but
the screenshot does not display the individual excluded accounts.

## Baseline

The application's Users and groups page initially showed Ana Maria as
the only assigned principal.

Ana's original direct application assignment was retained during the
capstone.

Evidence:

- `../screenshots/L17/01-application-baseline-assignments-redacted.png`

## Configuration

### Temporary Group and Application Assignment

Created the assigned security group `grp-l17-capstone-access` and added
Ana Maria and Andrei as direct members.

Assigned the group to the existing Microsoft Entra SAML Toolkit
enterprise application.

The application assignment page then showed:

- Ana Maria's original direct assignment.
- The temporary capstone group assignment.

Andrei did not receive a separate direct application assignment in the
captured configuration.

Evidence:

- `../screenshots/L17/02-capstone-group-members-redacted.png`
- `../screenshots/L17/03-application-capstone-group-assignment-redacted.png`

### Conditional Access

Configured `CA-L17-Capstone-MFA` with:

- Included group: `grp-l17-capstone-access`.
- Specific user exclusions configured.
- One target resource configured for the capstone application.
- Grant access with the built-in Multifactor authentication strength.
- No additional conditions selected.
- No session controls selected.
- Policy state: On.

The separate Require multifactor authentication checkbox was not
selected alongside Require authentication strength.

The captured configuration shows the included group, one target resource,
the selected authentication strength and the enabled policy state.
The resource name and individual exclusions are not expanded in these
screenshots.

Evidence:

- `../screenshots/L17/04-capstone-policy-user-scope-redacted.png`
- `../screenshots/L17/05-capstone-policy-mfa-enabled-redacted.png`

## Validation Results

| Test | Observed result | Evidence |
|---|---|---|
| Ana Entra sign-in | Success; multifactor authentication required; MFA satisfied by a claim in the token | 06 |
| Alex unassigned sign-in | Denied with AADSTS50105 | 07 |
| Andrei sign-in while assigned through the group | Success; multifactor authentication required; MFA satisfied by a claim in the token | 02, 03 and 08 |
| Andrei group membership removal | Group membership changed from Ana and Andrei to Ana only | 09 |
| Andrei sign-in after removal | Denied with AADSTS50105 | 10 |
| Membership-removal audit | Remove member from group operation succeeded; modified properties identify the capstone group | 11 |
| Application assignment cleanup | Ana's original direct assignment remained; capstone group assignment was absent | 12 |
| Temporary-object cleanup | Successful group deletion, group application-assignment removal and Conditional Access policy deletion operations recorded | 13 |

### Ana's Sign-in

Ana's sign-in event at `2026-10-10T16:47:45Z` showed:

- Application: Microsoft Entra SAML Toolkit.
- User: Ana Maria.
- Status: Success.
- Authentication requirement: Multifactor authentication.
- Additional details: MFA requirement satisfied by claim in the token.

This demonstrates successful Entra sign-in with the MFA requirement
satisfied. A new interactive MFA prompt was not required for that event.

Evidence:

- `../screenshots/L17/06-ana-success-capstone-mfa-redacted.png`

### Alex's Negative Test

Alex's attempt at `2026-10-10T16:48:35Z` was denied with `AADSTS50105`.

The error explained that the application required assignment and Alex
had neither a qualifying group membership nor a direct assignment.

This validates application assignment enforcement.

Evidence:

- `../screenshots/L17/07-alex-unassigned-access-denied-redacted.png`

### Andrei's Temporary Access

While Andrei was a direct member of the assigned capstone group, his
sign-in event at `2026-10-10T16:50:45Z` showed:

- Application: Microsoft Entra SAML Toolkit.
- User: Andrei.
- Status: Success.
- Authentication requirement: Multifactor authentication.
- Additional details: MFA requirement satisfied by claim in the token.

The group membership, application assignment and sign-in evidence
together support the temporary group-based access scenario.

Evidence:

- `../screenshots/L17/08-andrei-group-access-mfa-success-redacted.png`

### Access Removal

Removed Andrei from `grp-l17-capstone-access`.

The refreshed Members page showed only Ana Maria remaining.

A subsequent sign-in attempt at `2026-10-10T17:02:42Z` was denied with
`AADSTS50105`, indicating that Andrei no longer had a qualifying application
assignment.

The audit evidence also showed a successful Remove member from group
operation, with `grp-l17-capstone-access` identified in the modified
properties.

Evidence:

- `../screenshots/L17/09-andrei-removed-from-capstone-group-redacted.png`
- `../screenshots/L17/10-andrei-access-denied-after-removal-redacted.png`
- `../screenshots/L17/11-andrei-membership-removal-audit-redacted.png`

## Application Limitation and Evidence Boundaries

During Andrei's positive test, the SAML Toolkit displayed:

> Object reference not set to an instance of an object.

The corresponding Entra sign-in event was successful.

Successful Entra authentication and application assignment checks do not
prove that the application established a usable session after processing
the SAML response. End-to-end Toolkit session establishment could not be
verified for that attempt.

The raw SAML response displayed on the error page was excluded from the
published evidence.

The positive sign-in screenshots show the Basic info tab. They establish
the overall sign-in result and MFA requirement, but do not show the
individual evaluation result for `CA-L17-Capstone-MFA`. The report therefore
does not attribute the MFA outcome exclusively to that policy.

Claudiu was available as a second negative-control user. No observed
result is claimed for him in the screenshot-backed acceptance results.

## Cleanup

Removed the temporary capstone configuration:

- Deleted `CA-L17-Capstone-MFA`.
- Removed the application assignment for `grp-l17-capstone-access`.
- Deleted `grp-l17-capstone-access`.

The application assignment page returned to its original captured
baseline, showing only Ana Maria's direct assignment.

The cleanup audit list recorded successful operations for:

- Remove app role assignment from group.
- Delete group.
- Delete conditional access policy.

The policy deletion entry was identified as a soft deletion.

Evidence:

- `../screenshots/L17/12-application-assignments-after-cleanup-redacted.png`
- `../screenshots/L17/13-capstone-cleanup-audit-redacted.png`

## Security and Evidence Handling

- Used test identities for access validation.
- Limited the temporary access group to Ana Maria and Andrei.
- Used a scoped Conditional Access policy.
- Preserved Ana's original direct application assignment.
- Removed temporary access before completing cleanup.
- Published redacted screenshots.
- Excluded raw SAML responses and authentication secrets.
- Used sign-in and audit evidence to distinguish authentication outcomes
  from directory changes and application-side behavior.

## Lessons Learned

- Application assignment and successful authentication are separate checks.
- Group membership can provide temporary application access.
- Removing the relevant group membership can prevent a subsequent sign-in
  when no other assignment path remains.
- MFA can be satisfied by an existing token claim without a new prompt.
- Basic sign-in details do not establish which individual policy caused
  an MFA requirement.
- A successful Entra sign-in does not guarantee successful application-side
  SAML processing.
- Cleanup requires verifying the final assignment state and preserving
  evidence of the removal operations.

## Completion Assessment

Completed the scoped capstone for Entra authentication, MFA requirement
validation, application assignment enforcement, temporary access removal
and cleanup.

The evidence demonstrates Alex's assignment denial, Andrei's successful
Entra sign-in while assigned through the capstone group, and Andrei's
assignment denial after removal.

Application-side SAML session establishment remains subject to the
documented Toolkit processing limitation.
