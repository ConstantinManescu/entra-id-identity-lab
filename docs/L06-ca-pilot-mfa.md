# L06 — Conditional Access Pilot MFA

## Objective

Deploy and validate a Conditional Access MFA policy for a small pilot group, test its scope and sign-in outcomes, demonstrate disabling the policy, and leave the tenant ready for the next lab.

## Environment and scope

- Tenant: Microsoft Entra ID lab tenant.
- Licensing: Microsoft Entra ID P2 assigned to the four test users.
- Pilot users: Ana Maria and Claudiu Auditor.
- Control users: Andrei and Alex.
- Pilot security group: `grp-ca-l06-mfa-pilot`, with Ana and Claudiu as direct members.
- Sign-in testing: the existing `entra-lab-oidc-app` application.
- Administrative accounts: the main administrator and `entra-admin-01`.
- Emergency access accounts: `breakglass-01` and `breakglass-02`.

The test users already had other group memberships. A dedicated assigned group kept the L06 policy scope explicit without changing the groups used by earlier labs.

## Pilot policy configuration

Created `CA-L06-Pilot-Require-MFA` with the following settings:

| Setting | Configuration |
|---|---|
| Included users | Members of `grp-ca-l06-mfa-pilot` |
| Excluded users | Main administrator, `entra-admin-01`, `breakglass-01`, and `breakglass-02` |
| Target resources | All resources; no resource exclusions |
| Grant control | Grant access and require authentication strength |
| Authentication strength | Built-in Multifactor authentication |
| Additional conditions | None configured |
| Session controls | None configured |
| Initial state | Report-only |

The policy targeted all resources. The OIDC application was used to generate test sign-ins; it was not the policy's only target resource.

Used the authentication-strength control rather than also selecting the separate Require multifactor authentication checkbox. The portal warning about these controls being mutually exclusive did not indicate a failed configuration.

## Security Defaults transition and administrator protection

Security Defaults were initially enabled. During troubleshooting, the expected Report-only evaluation was not visible in the sign-in being inspected. This observation alone did not establish the cause.

Created `CA-Lab-Admins-Require-MFA` for the main administrator and `entra-admin-01`, with the emergency access accounts excluded. The policy targeted all resources and required the built-in Multifactor authentication strength.

Disabled Security Defaults, enabled the administrator policy, and confirmed that `entra-admin-01` could still access the Entra admin center. The administrator had Microsoft Authenticator and a passkey registered.

Later in the lab, added broader MFA and legacy authentication policies to provide ongoing protection while the L06 pilot returned to Report-only. These policies cover the MFA and legacy authentication controls configured here; they are not presented as a complete replica of every Security Defaults behavior.

## Validation results

| Scenario | Observed result | Evidence |
|---|---|---|
| Pilot membership | Ana and Claudiu were the two direct members | 01 |
| Report-only evaluation | The pilot policy returned Report-only: Success in the sign-in selected for Ana | 05 |
| Pilot enforcement | The pilot policy was enabled and returned Success in Ana's selected sign-in | 06–07 |
| Ana MFA satisfaction | Authentication details showed a previously satisfied MFA claim and a successful MFA requirement | 08 |
| Claudiu negative test | Password authentication succeeded; the mobile app notification step did not succeed; the sign-in failed | 09 |
| Andrei scope control | The pilot policy returned Not applied in the sign-in selected for Andrei | 10 |
| Pilot disablement | The pilot policy was switched Off | 11 |
| Final pilot configuration | The pilot was returned to Report-only | 12 and 17 |

### Ana's successful sign-in

The enabled pilot policy returned Success. The Authentication details tab showed that the MFA requirement was satisfied using a previously satisfied authentication claim.

This demonstrates successful MFA requirement evaluation. The captured event does not demonstrate a new Authenticator approval during that particular sign-in. A policy requiring MFA does not necessarily produce a new prompt when the session already contains acceptable authentication evidence.

### Claudiu's unsuccessful MFA attempt

During the negative test, selected "It's not me" in Microsoft Authenticator. The browser reported that the sign-in had been rejected.

The attempts were not initially visible in the sign-in logs being inspected. Later, the failure events were located. The captured event shows successful password authentication, an unsuccessful mobile app notification step, and a failed sign-in. Its displayed result detail is Other; no specific rejection error code is asserted.

The event also lists Per-user MFA alongside Conditional Access and Authentication Strength(s). Consequently, this is evidence of an unsuccessful MFA sign-in while multiple MFA enforcement mechanisms were active. It does not isolate the L06 policy as the sole source of the MFA requirement.

After testing, changed Claudiu's per-user MFA state to Disabled so ongoing MFA enforcement could come from Conditional Access. His registered Authenticator method was retained. Screenshot 09 remains historical evidence from before that change.

### Diagnostic messages

The Diagnose menu also displayed 50203 messages concerning Authenticator registration or snoozing a registration notification. These entries were associated with other attempts that the tester identified as successful, and Claudiu already had Authenticator registered.

Those diagnostic entries were not used as evidence of the rejected MFA attempt. No authentication-method reset or re-registration was performed to address them.

### Scope and rollback limits

Andrei's selected event showed that the pilot policy did not apply. Successful Andrei and Alex sign-ins were visible in the surrounding log list, but the captured detailed policy result supports the Andrei control case.

Screenshot 11 proves that the policy was disabled. It does not by itself prove a separate post-disablement sign-in test. The policy was subsequently returned to Report-only, as shown by screenshots 12 and 17.

## Baseline policies

### CA-Baseline-Require-MFA

- Include all users.
- Exclude the two emergency access accounts.
- Target all resources without resource exclusions.
- Grant access and require the built-in Multifactor authentication strength.
- Leave additional conditions and session controls unconfigured.
- Final state: On.

### CA-Baseline-Block-Legacy-Authentication

- Include all users.
- Exclude the two emergency access accounts.
- Target all resources.
- Configure the Client apps condition.
- Select only Exchange ActiveSync clients and Other clients.
- Leave Browser and Mobile apps and desktop clients unchecked in this policy.
- Grant control: Block access.
- Final state: On.

The screenshots document the baseline configuration and enabled states. They do not demonstrate an actual legacy-protocol sign-in being blocked.

## Final tenant state

| Item | Final state |
|---|---|
| `CA-L06-Pilot-Require-MFA` | Report-only |
| `CA-Lab-Admins-Require-MFA` | On |
| `CA-Baseline-Require-MFA` | On |
| `CA-Baseline-Block-Legacy-Authentication` | On |
| Security Defaults | Disabled |
| Claudiu per-user MFA | Disabled after testing; recorded from the configuration change |
| Pilot group and test users | Retained |
| Registered authentication methods | Retained |

Screenshot 17 confirms the saved states of all four Conditional Access policies. Security Defaults being disabled is shown separately in screenshot 13. Claudiu's later per-user MFA change is recorded here without a separate screenshot.

The all-users baseline can now require MFA for Andrei and Alex even though they are outside the L06 pilot. Not applied for the pilot does not mean that no other policy requires MFA.

No further rollback was performed. The retained configuration is the starting point for L07 — Conditional Access controlled block, where a separate narrowly scoped test policy can be introduced.

## Evidence

Screenshots are stored in `screenshots/L06/`. Personal identifiers and sensitive values were redacted before publication.

| Screenshot | Description |
|---|---|
| [01-pilot-group-members-redacted.png](../screenshots/L06/01-pilot-group-members-redacted.png) | Ana and Claudiu in the dedicated pilot group |
| [02-policy-account-exclusions-redacted.png](../screenshots/L06/02-policy-account-exclusions-redacted.png) | Administrator and emergency account exclusions during policy creation |
| [03-policy-mfa-authentication-strength-redacted.png](../screenshots/L06/03-policy-mfa-authentication-strength-redacted.png) | MFA authentication-strength selection during policy creation |
| [04-policy-report-only-configuration-redacted.png](../screenshots/L06/04-policy-report-only-configuration-redacted.png) | Saved initial Report-only policy details |
| [05-ana-report-only-policy-result-redacted.png](../screenshots/L06/05-ana-report-only-policy-result-redacted.png) | Pilot Report-only: Success evaluation |
| [06-policy-enabled-redacted.png](../screenshots/L06/06-policy-enabled-redacted.png) | Pilot and administrator MFA policies enabled during testing |
| [07-ana-enforced-policy-success-redacted.png](../screenshots/L06/07-ana-enforced-policy-success-redacted.png) | Enabled pilot returned Success |
| [08-ana-mfa-authentication-details-redacted.png](../screenshots/L06/08-ana-mfa-authentication-details-redacted.png) | Ana's MFA requirement satisfied through an existing claim |
| [09-claudiu-mfa-not-completed-redacted.png](../screenshots/L06/09-claudiu-mfa-not-completed-redacted.png) | Password succeeded and Authenticator notification did not succeed |
| [10-andrei-policy-not-applied-redacted.png](../screenshots/L06/10-andrei-policy-not-applied-redacted.png) | Pilot scope-control result |
| [11-policy-rollback-off-redacted.png](../screenshots/L06/11-policy-rollback-off-redacted.png) | Pilot policy disabled |
| [12-policy-final-report-only-redacted.png](../screenshots/L06/12-policy-final-report-only-redacted.png) | Pilot returned to Report-only |
| [13-security-defaults-disabled-redacted.png](../screenshots/L06/13-security-defaults-disabled-redacted.png) | Security Defaults disabled |
| [14-admin-authentication-methods-redacted.png](../screenshots/L06/14-admin-authentication-methods-redacted.png) | Administrator's registered Authenticator and passkey |
| [15-baseline-mfa-policy-configuration-redacted.png](../screenshots/L06/15-baseline-mfa-policy-configuration-redacted.png) | Baseline all-users MFA configuration |
| [16-legacy-authentication-block-configuration-redacted.png](../screenshots/L06/16-legacy-authentication-block-configuration-redacted.png) | Legacy client selection and Block access control |
| [17-final-policy-states-redacted.png](../screenshots/L06/17-final-policy-states-redacted.png) | Final saved states of all four policies |

## Outcome

Completed the Conditional Access MFA pilot, captured a successful enabled-policy evaluation, documented MFA satisfaction through an existing claim, recorded an unsuccessful MFA attempt and its enforcement limitation, checked an out-of-scope user, and demonstrated policy disablement. Left the pilot in Report-only with the administrator and baseline protection policies enabled for the next lab.

## References

- [Require MFA for all users using authentication strength](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-all-users-mfa-strength)
- [Block legacy authentication](https://learn.microsoft.com/en-us/entra/identity/conditional-access/policy-block-legacy-authentication)
- [Conditional Access Report-only mode](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [Per-user MFA states and Conditional Access](https://learn.microsoft.com/en-us/entra/identity/authentication/howto-mfa-userstates)