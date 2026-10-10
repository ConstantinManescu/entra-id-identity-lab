# L11 — Identity Protection and Labeled Simulation

**Status:** Core validation completed
**Validation date:** 2026-10-08
**Final verification:** See the final checks and cleanup section.

## Objective

Configure separate Conditional Access policies for user risk and
sign-in risk, validate their matching through What If, and test
user-risk remediation using a deliberately introduced compromise
condition for Alex.

The exercise demonstrates:

- The distinction between user risk and sign-in risk.
- Policy evaluation in report-only mode.
- Enforcement of a user-risk remediation requirement.
- Secure password change and resolution of user risk.
- Investigation of policy results and identity risk history.

## Environment and scope

- Microsoft Entra tenant: Default Directory.
- Alex was the only test user in the L11 pilot; other test users were outside its scope.
- Microsoft Entra ID P2 licensing was reported active for the test users.
- L11 pilot group: `grp-entra-l11-risk-pilot`.
- Pilot member: Alex only.
- Tenant-native administrative account: `entra-admin-01`.
- Administrative and emergency accounts were excluded from the policies.
- Both policy overview screenshots show one included group and four
  excluded users.
- Existing baseline MFA protection remained present.
- No Azure infrastructure resources were required.

Alex was selected for the password-change test so that Ana would not
need to change her password for this exercise.

## Policy configuration

### User-risk policy

**Name:** `CA-L11-UserRisk-High-PasswordChange`

| Setting | Configuration |
|---|---|
| Included users | L11 pilot group containing Alex |
| Excluded identities | Administrative and emergency accounts |
| Target resources | All resources |
| User risk | High |
| Sign-in risk | Not configured |
| Remediation requirement | MFA and password change |
| Session requirement | New sign-in for each session |
| Initial state | Report-only |
| Enforcement test state | Enabled |

Screenshot 01 records the initial report-only overview.

Screenshot 04 shows the What If grant requirements as MFA authentication
strength and password change, with sign-in frequency set to Every time.

Screenshot 08 confirms the policy was Enabled during the captured
enforcement event.

The initial policy overview displays one included client-app category.
The captured enforcement evaluation displays Client app as Not
configured. These screenshots represent different points in the
configuration lifecycle; the later event is the evidence for the
evaluated enforcement conditions.

### Sign-in-risk policy

**Name:** `CA-L11-SignInRisk-MediumHigh-MFA`

| Setting | Configuration |
|---|---|
| Included users | L11 pilot group containing Alex |
| Excluded identities | Administrative and emergency accounts |
| Target resources | All resources |
| Sign-in risk | Medium and High |
| User risk | Not configured |
| Grant requirement | Multifactor authentication |
| Session requirement | New sign-in for each session |
| Validation state | Report-only |

This policy was evaluated through What If and report-only reporting.
Live enforcement of an automatically detected risky sign-in was not
demonstrated.

## Procedure and observed results

### 1. Configure the pilot and policies

A dedicated pilot group was used to restrict the L11 test to Alex.

Separate policies were created for High user risk and Medium/High
sign-in risk. Both policies initially used report-only mode.

During user-risk policy creation, error 1090 stated that the password
change control required a user-risk condition. The configuration was
corrected to explicitly enable the High user-risk condition.

### 2. Evaluate sign-in risk through What If

A What If evaluation was performed with:

- Sign-in risk: Medium.
- User risk: No risk.

The result listed:

- `CA-Baseline-Require-MFA`, state On.
- `CA-L11-SignInRisk-MediumHigh-MFA`, state Report-only.

The L11 sign-in-risk policy matched the hypothetical scenario and
required MFA with sign-in frequency set to Every time.

Evidence: screenshot 03.

### 3. Evaluate user risk through What If

A separate What If evaluation was performed with:

- User risk: High.
- Sign-in risk: left unspecified in the captured input.

The result listed:

- `CA-Baseline-Require-MFA`, state On.
- `CA-L11-UserRisk-High-PasswordChange`, state Report-only.

The L11 user-risk policy matched the hypothetical scenario and showed
MFA, password change and sign-in frequency requirements.

Evidence: screenshot 04.

What If evaluates supplied hypothetical conditions. It does not create
a risk detection or perform user remediation.

### 4. Resolve Microsoft Graph authentication and permission errors

The first Graph Explorer request returned an error stating that the API
was not supported for MSA accounts.

Graph Explorer was then signed in with the tenant-native administrative
account, `entra-admin-01`.

A subsequent request returned HTTP 403 with the message that required
scopes were missing from the token.

The delegated permission `IdentityRiskyUser.ReadWrite.All` was consented
for Graph Explorer before the request was retried.

These were separate issues:

- The first concerned the authentication context.
- The second concerned the API permission available in the token.

### 5. Introduce the administrator-confirmed compromise simulation

The following Microsoft Graph action was used:

```http
POST https://graph.microsoft.com/v1.0/identityProtection/riskyUsers/confirmCompromised
Content-Type: application/json
```

Sanitized request body:

```json
{
  "userIds": [
    "<Alex-object-id>"
  ]
}
```

Only Alex was targeted.

The resulting risky-user record showed:

- Risk state: Confirmed compromised.
- Risk level: High.
- Risk last updated: 2026-10-08 at 13:24, as displayed in the portal.

The subsequent risk history identifies the actor as
Entra Lab Administrator 01.

Evidence: screenshots 05 and 07.

This was a deliberate administrator-confirmed simulation. It does not
demonstrate an independently detected credential leak or attacker login.

### 6. Review the report-only sign-in result

Alex signed in while the user-risk policy was in report-only mode.

The Report only tab listed the user-risk policy with:

- Grant controls: `MfaAndChangePassword`.
- Session controls: `SignInFrequency`.
- Result displayed as `Report-only: User acti...`, consistent with
  User action required.

The sign-in-risk policy appeared as Report-only: Not applied in the
same captured view.

This demonstrated that the introduced user-risk condition matched the
user-risk policy without establishing a matching sign-in-risk condition.

Evidence: screenshot 06.

### 7. Enable and test user-risk remediation

The user-risk policy was changed from Report-only to Enabled.

Alex received a password-change requirement and completed the password
change. The prompt itself was not captured.

The captured enforced policy evaluation shows:

| Evaluation item | Captured result |
|---|---|
| Policy state | Enabled |
| Overall policy result | Failure |
| User: Alex | Matched |
| Resource: Microsoft Graph | Matched |
| User risk | Matched |
| Grant controls | Not satisfied |
| Session controls | Enforced |

Evidence: screenshot 08.

This event proves the enabled policy matched the request and its grant
requirements had not yet been satisfied at that point. It documents
the remediation interruption, not a final successful sign-in.

### 8. Verify secure password change and risk resolution

Alex's risk history records:

| Portal-displayed time | Activity |
|---|---|
| 2026-10-08 13:24 | Admin confirmed user compromised |
| 2026-10-08 13:41 | User performed secured password change |

Afterward, the risky-user details showed:

- Risk level: No risk.
- Identity Risk Score: 0.

Evidence: screenshot 07.

This provides system-recorded evidence of the secure password change
and subsequent risk resolution despite the missing prompt screenshot.

### 9. Investigate the sign-in log results

Initial inspection found three sign-in events around the test period
showing the policy as Not applied.

The enforced policy details captured in screenshot 08 subsequently
provided evidence of an Enabled policy with matching assignments and
user risk, but unsatisfied grant controls.

The screenshots do not prove that ingestion delay caused the initial
difficulty finding that event.

Sign-ins after risk resolution may no longer match a policy requiring
High user risk. The final report therefore distinguishes:

- The matched enforcement interruption.
- The recorded secure password change.
- The subsequent No risk state.

## Results

| Validation | Outcome |
|---|---|
| User-risk policy configuration | Captured |
| Sign-in-risk policy configuration | Captured |
| Medium sign-in-risk What If matching | Validated |
| High user-risk What If matching | Validated |
| Administrator-confirmed High user risk | Validated |
| User-risk report-only evaluation | Captured |
| Enabled user-risk policy matching | Validated |
| Unsatisfied grant controls during enforcement | Captured |
| Secured password change | Recorded in risk history |
| Risk resolution to No risk | Validated |
| Password-change prompt screenshot | Not captured |
| Final successful enforced sign-in screenshot | Not captured |
| Automated sign-in-risk detection and enforcement | Not demonstrated |
| Subsequent normal sign-in and Ana control check | See final checks |

## Evidence

All paths are relative to this document.

1. [User-risk policy in report-only mode](../screenshots/L11/01-user-risk-policy-report-only-redacted.png)
2. [Sign-in-risk policy in report-only mode](../screenshots/L11/02-sign-in-risk-policy-report-only-redacted.png)
3. [Medium sign-in-risk What If simulation](../screenshots/L11/03-sign-in-risk-what-if-simulation-redacted.png)
4. [High user-risk What If simulation](../screenshots/L11/04-user-risk-what-if-simulation-redacted.png)
5. [Alex confirmed compromised with High risk](../screenshots/L11/05-alex-confirmed-compromised-simulation-redacted.png)
6. [Alex user-risk report-only result](../screenshots/L11/06-alex-user-risk-report-only-result-redacted.png)
7. [Alex secured password change and No risk](../screenshots/L11/07-alex-user-risk-remediated-redacted.png)
8. [Enabled user-risk policy enforcement interruption](../screenshots/L11/08-alex-enforced-user-risk-policy-result-redacted.png)

## Final checks and cleanup

The supplied screenshots establish the core validation result.
Final checks below must be recorded separately; the screenshots do not
establish that these actions have already been completed.

- [ ] Alex can sign in normally using his new password.
- [ ] Ana's control sign-in confirms the L11 policies do not apply.
- [ ] Both L11 policies are set to Off after testing.
- [ ] Alex remains at No risk.
- [ ] Graph Explorer administrative session is signed out.
- [ ] Graph Explorer permission consent retained or revoked is recorded.
- Screenshot 08 has its IP address removed in the reviewed repository copy.
- The eight retained screenshots were reviewed during repository cleanup.

The policies and pilot group may be retained for reference with the
policies disabled.

Signing out of Graph Explorer does not revoke its permission consent.

## Limitations

- User risk was deliberately introduced through administrative
  confirmation rather than an automated compromise detection.
- Sign-in-risk matching was tested through What If; no live automated
  sign-in-risk enforcement was demonstrated.
- The password-change prompt screenshot was not captured.
- The password change is supported by the operator's observation and
  the system-recorded risk history.
- Screenshot 08 shows the enforcement interruption, not a final
  successful policy result.
- Cropped What If screenshots do not display every input field.
- Excluded-user counts are visible, but the individual excluded
  identities are not displayed in the policy overview screenshots.

## Lessons learned

- User risk and sign-in risk require separate interpretation.
- Entra administrator roles and delegated Graph permissions are
  independent requirements.
- Report-only mode supports validation before enforcement.
- A Failure result can document an enforced requirement that has not
  yet been satisfied.
- Identity risk history provides evidence of remediation even when the
  user-facing prompt was not captured.
- Portfolio evidence must distinguish hypothetical evaluation,
  administrative simulation, enforcement interruption and remediation.

## Microsoft documentation

- [Confirm compromised using Microsoft Graph](https://learn.microsoft.com/en-us/graph/api/riskyuser-confirmcompromised?view=graph-rest-1.0)
- [Use Microsoft Graph Explorer](https://learn.microsoft.com/en-us/graph/graph-explorer/graph-explorer-overview)
- [Conditional Access report-only results](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [Conditional Access grant controls](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-grant)
- [Remediate risks and unblock users](https://learn.microsoft.com/en-us/entra/id-protection/howto-identity-protection-remediate-unblock)
- [Conditional Access What If tool](https://learn.microsoft.com/en-us/entra/identity/conditional-access/what-if-tool)
