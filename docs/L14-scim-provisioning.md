# L14 — SCIM Application Provisioning

**Status:** COMPLETED

**Completed:** 2026-10-09

## Objective

Configure outbound SCIM provisioning from Microsoft Entra ID to a
dedicated test endpoint. Validate account creation, assignment-based
exclusion, attribute updates and account deactivation.

## Environment

- Enterprise application: `entra-l14-scim-app`
- Pilot security group: `grp-l14-scim-pilot`
- Target: Flexi-SCIM isolated test instance
- Test users: Ana, Alex, Andrei and Claudiu
- Microsoft Entra ID P2 licenses assigned to all four test users
- Initial pilot members: Ana and Alex
- Negative control: Andrei
- Claudiu was not used for an active test

The application and pilot group were dedicated to L14.

## Application Assignment

The pilot group was assigned to the enterprise application.
Ana and Alex received application assignment through the group.

Evidence:
`../screenshots/L14/01-app-pilot-group-assignment-redacted.png`

## Provisioning Configuration

The application used a SCIM endpoint and a bearer token to connect
to the target service. Credentials and private endpoint details are
not included in this report.

The captured provisioning overview showed the initial synchronization
paused before a cycle had completed. This screenshot documents the
configuration overview, not a successful connection-test message.

Subsequent successful account creation confirms that the integration
could communicate with the target.

Evidence:
`../screenshots/L14/02-provisioning-overview-redacted.png`

## Attribute Mappings

| Source | Target | Mapping type |
|---|---|---|
| userPrincipalName | userName | Direct; matching precedence 1 |
| displayName | displayName | Direct |
| givenName | name.givenName | Direct |
| surname | name.familyName | Direct |
| objectId | externalId | Direct |
| L14-SCIM-Initial | title | Constant |
| Default IsSoftDeleted expression | active | Expression |

The existing account-state expression was retained.
The title constant was later changed to `L14-SCIM-Updated`.

Evidence:
`../screenshots/L14/03-user-attribute-mappings-redacted.png`

## Validation Results

### Account Creation

Ana and Alex were created successfully in the target application.

The target dashboard showed both accounts as Active, with the title
`L14-SCIM-Initial`. No target group objects were present.

Evidence:
`../screenshots/L14/04-ana-alex-provisioned-active-redacted.png`

### Negative Control

Andrei's on-demand provisioning attempt was skipped.

The scope evaluation showed:

- Assigned to the application: False
- SkipReason: NotEffectivelyEntitled

The result demonstrated that an existing, enabled Entra account
without application entitlement was not provisioned.

Evidence:
`../screenshots/L14/05-andrei-out-of-scope-redacted.png`

### Attribute Update

The title constant was changed to `L14-SCIM-Updated`.

Ana's target account showed the updated title while remaining Active.
At the captured point, Alex still had the initial title.

This was a mapping-driven update; Ana's Entra profile did not need
to be modified.

Evidence:
`../screenshots/L14/06-ana-attribute-update-redacted.png`

### Deprovisioning

Following removal of Alex's pilot-group membership, his target account
was shown as Deactivated while Ana remained Active.

Alex's target account was retained rather than deleted.

Evidence:
`../screenshots/L14/07-alex-deprovisioned-inactive-redacted.png`

### Provisioning Logs

Microsoft Entra provisioning logs recorded:

| User | Action | Status |
|---|---|---|
| Ana | Create | Success |
| Alex | Create | Success |
| Andrei | Other | Skipped |
| Ana | Update | Success |
| Alex | Disable | Success |
| Ana | Disable | Success |

The later successful Disable operation for Ana provides evidence
of her subsequent target-account deactivation.

Evidence:
`../screenshots/L14/08-provisioning-logs-redacted.png`

## Evidence Limitations

The target dashboard provided sufficient evidence of account status
and title changes; no JSON screenshot was required.

The evidence does not establish the number or timing of completed
scheduled synchronization cycles.

## Cleanup

Successful disable operations were recorded for both pilot users.

Pausing the provisioning job, resetting the target instance and
removing the stored integration credential have not yet been
confirmed in this report.

Before retiring the integration:

1. Confirm both target accounts are inactive.
2. Pause provisioning.
3. Reset the dedicated Flexi-SCIM instance.
4. Remove the stored credential or delete the dedicated application.
5. Retain the Entra test users and their licenses for later labs.

## Key Findings

- Application assignment and provisioning are separate from sign-in.
- Group assignment can control user provisioning without creating
  group objects in the target.
- Matching attributes identify existing target accounts.
- Constant mappings can drive target attribute updates.
- Removing application entitlement can deactivate a target account
  without deleting the Entra user.
- Provisioning logs distinguish successful operations from
  intentionally skipped users.

## References

- https://learn.microsoft.com/en-us/entra/identity/app-provisioning/use-scim-to-provision-users-and-groups
- https://learn.microsoft.com/en-us/entra/identity/app-provisioning/provision-on-demand
- https://learn.microsoft.com/en-us/entra/identity/app-provisioning/how-provisioning-works
- https://etelej.com/apps/flexi-scim
