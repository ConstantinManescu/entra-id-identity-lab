# L04 — MFA Registration and Self-Service Password Reset

## Objective

The objective of this lab was to configure and validate a controlled Microsoft Entra self-service password reset (SSPR) deployment.

The lab used a dedicated pilot group, Microsoft Entra ID P2 licensing, combined security-information registration, two-method password-reset verification, and both positive and negative test scenarios.

The lab demonstrated:

- Microsoft Entra authentication-method registration
- Microsoft Authenticator registration
- Passkey registration
- SSPR licensing requirements
- Selected-group SSPR targeting
- Two-method identity verification
- Successful cloud-only password reset
- Successful authentication after the password reset
- Denial of SSPR for a user outside the pilot group
- Authentication-method and SSPR audit-log investigation
- Controlled deployment and rollback planning

Conditional Access was inventoried but not configured in this lab. Conditional Access enforcement is covered separately in later labs.

## Environment

The lab was completed using:

- Microsoft Entra admin center
- Microsoft Entra ID P2 trial
- Cloud-only Microsoft Entra identities
- Microsoft Authenticator
- Brave browser private sessions
- Dedicated non-administrator test users
- Dedicated SSPR pilot security group

The following identities were used:

| Identity | Purpose | Pilot membership |
|---|---|---|
| Ana Maria | Positive SSPR test user | Member |
| Andrei | Negative control user | Not a member |
| Administrative account | Configuration and audit review | Not used for end-user testing |
| Emergency access accounts | Tenant recovery | Excluded from testing |

The pilot security group was:

```text
grp-l04-mfa-sspr-pilot
```

Neither administrative nor emergency access accounts were added to the pilot group.

## Initial State

Before making changes, the existing tenant configuration was inventoried.

The initial review confirmed:

- The tenant initially had no active premium Entra product.
- Security Defaults was enabled.
- SSPR was disabled.
- Conditional Access configuration was unavailable before premium licensing.
- Microsoft Authenticator and several other authentication methods were available.
- SMS and voice authentication were not enabled through the Authentication Methods policy.
- No existing Conditional Access policies were modified.
- Emergency access accounts were kept outside the lab scope.

The pre-change state was recorded before activating the premium trial or enabling SSPR.

## Licensing

A Microsoft Entra ID P2 trial was activated.

P2 was selected because it includes the P1 capabilities required for this lab and supports later curriculum topics such as:

- Conditional Access
- Dynamic groups
- Privileged Identity Management
- Identity Protection
- Risk-based access policies

Qualifying licences were assigned to the users who participated in the controlled tests.

Licensing the negative-control user ensured that the negative result was caused by SSPR group scope rather than by a missing licence.

No Azure compute, storage, networking, or other billable Azure resources were created for this lab.

## Pilot Group

A dedicated assigned-membership security group was created:

```text
grp-l04-mfa-sspr-pilot
```

The group description identified it as the L04 MFA and SSPR pilot group.

Only Ana Maria was added to the pilot group.

Andrei remained outside the group so that he could be used as the negative-control user.

The following accounts were intentionally excluded:

- Global Administrator account
- Separate administrative account
- Emergency access accounts
- Other unrelated test users

This design limited the effect of the SSPR configuration and reduced the risk of accidental tenant lockout.

## Authentication Methods

The Authentication Methods policy was reviewed before the lab configuration.

The inventory included:

- Microsoft Authenticator
- Passkey/FIDO2
- Temporary Access Pass
- Software OATH tokens
- Email OTP
- SMS
- Voice call

The existing Authentication Methods policy was not unnecessarily narrowed because Security Defaults remained enabled.

Ana’s final security-information registration included:

- Phone
- Microsoft Authenticator
- Device-bound passkey in Microsoft Authenticator
- Password

Microsoft Authenticator notification was displayed as Ana’s normal sign-in method where applicable.

The existence of registered methods did not, by itself, enforce MFA or SSPR. Registration only made those methods available for compatible authentication and recovery operations.

## SSPR Configuration

SSPR was configured with the following scope:

```text
Self-service password reset enabled: Selected
Selected group: grp-l04-mfa-sspr-pilot
```

This meant that only users within the selected pilot group were eligible to use the configured SSPR service.

The authentication requirements were configured as follows:

```text
Number of methods required to reset: 2
```

Registration settings were configured as follows:

```text
Require users to register when signing in: Yes
Number of days before users are asked to reconfirm: 180
```

Notifications were configured as follows:

```text
Notify users on password resets: Yes
Notify all administrators when other administrators reset their passwords: Yes
```

Security Defaults remained enabled throughout the lab.

No Conditional Access policy was created, enabled, disabled, or modified during L04.

## Combined Security-Information Registration

Ana signed in through the Microsoft security-information experience and confirmed her registered authentication methods.

The registration page demonstrated that the same security-information experience can support multiple identity operations, including:

- Sign-in
- Multifactor authentication
- Password reset
- Passwordless authentication

Combined registration does not mean that MFA and SSPR are the same feature.

They can use common registered methods, but they remain separate processes with different policies and triggers:

- Authentication Methods policy determines which methods users can register and use.
- SSPR policy determines who can reset a password and how identity must be verified.
- Conditional Access determines when access requires MFA or another control.
- Authentication strengths determine which method combinations can satisfy a Conditional Access requirement.

## Initial Troubleshooting

During the initial SSPR test, the following error was encountered:

```text
SSPR_0011: Your organization hasn’t set up a password reset policy.
```

This error occurs before authentication-method verification. It indicates that Microsoft Entra could not find an applicable password-reset policy for the organization associated with the entered identity.

The troubleshooting process included:

1. Confirming that Ana was a cloud-only Microsoft Entra member.
2. Confirming that Ana had an active qualifying licence.
3. Confirming that Ana was a member of the selected pilot group.
4. Confirming that the correct tenant was active in the Entra admin center.
5. Confirming that the selected-group SSPR configuration had been saved.
6. Using Ana’s exact Microsoft Entra user principal name.
7. Retesting from a fresh private browser session.
8. Allowing time for the updated configuration to propagate.

After the tenant, identity, licensing, group scope, and SSPR policy were verified, the SSPR workflow became available and the test completed successfully.

This troubleshooting exercise demonstrated the importance of interpreting SSPR error codes according to the stage at which the reset process fails.

## Positive Validation — Ana Maria

Ana Maria was used as the positive test user.

Before testing, the following conditions were confirmed:

- Ana was a cloud-only Microsoft Entra member.
- Ana was not assigned an administrator role.
- Ana had a qualifying Microsoft Entra licence.
- Ana was a member of `grp-l04-mfa-sspr-pilot`.
- Ana had sufficient registered security information.
- Two verification methods were required by the SSPR policy.

The password-reset test was started from:

```text
https://aka.ms/sspr
```

Ana completed the required identity-verification gates and successfully selected a new password.

The final SSPR page confirmed:

```text
Your password has been reset
```

A new private browser session was then opened.

Ana successfully signed in using the new password and completed the applicable authentication requirements.

This confirmed that:

- The SSPR workflow completed successfully.
- The new cloud password was active.
- Ana’s account remained usable after the reset.
- The registered methods and selected-group SSPR policy operated correctly.

## Positive Audit-Log Validation

The Microsoft Entra audit logs recorded Ana’s successful reset operation.

The relevant event showed:

```text
Service: Self-service Password Management
Activity type: Self-service password reset flow activity progress
Status: Success
Status reason: User successfully reset password
```

This provided administrative evidence in addition to the end-user success page.

The published screenshot was redacted to remove:

- Full user principal name
- Public IP address
- Object ID
- Correlation ID
- Other identifying information

## Negative Validation — Andrei

Andrei was used as the negative-control user.

Before testing, the following conditions were confirmed:

- Andrei was a Microsoft Entra member.
- Andrei was not assigned an administrator role.
- Andrei had a qualifying Microsoft Entra licence.
- Andrei was not a member of `grp-l04-mfa-sspr-pilot`.

Giving Andrei a qualifying licence removed licensing as the reason for failure. The primary difference between the positive and negative scenarios was pilot-group membership.

Andrei attempted to use the SSPR portal but was denied.

The user-facing message stated that password reset was not enabled for his account.

This demonstrated that merely having a qualifying licence does not automatically place a user within the configured SSPR scope.

## Negative Audit-Log Validation

The Microsoft Entra audit logs recorded Andrei’s unsuccessful attempt.

The relevant event showed:

```text
Service: Self-service Password Management
Activity type: Self-service password reset flow activity progress
Status: Failure
Status reason: This user is not a member of the password reset users group.
```

This confirmed that the failure was caused by the selected-group SSPR scope.

The result was not caused by:

- Missing tenant licensing
- Missing user licensing
- Password writeback
- An administrator-specific reset policy
- A general Microsoft Entra service failure

The published screenshot was redacted to remove:

- Full user principal name
- Public IP address
- Object ID
- Correlation ID
- Other identifying information

## Results

The lab produced the following results:

| Test | Expected result | Actual result |
|---|---|---|
| P2 trial activation | Premium Entra capabilities available | Passed |
| Pilot-group creation | Dedicated assigned security group created | Passed |
| SSPR selected-group targeting | Only pilot members eligible | Passed |
| Ana security-information registration | Required methods available | Passed |
| Two-method password reset | Ana completes the required verification | Passed |
| Cloud password reset | New password accepted | Passed |
| Post-reset sign-in | Ana signs in using the new password | Passed |
| Andrei negative test | Non-pilot user denied | Passed |
| Positive audit validation | Successful reset visible in logs | Passed |
| Negative audit validation | Group-scope failure visible in logs | Passed |
| Emergency-account protection | Emergency accounts remain outside the pilot | Passed |
| Conditional Access isolation | No CA policies modified in L04 | Passed |

## Evidence

Evidence is stored under:

```text
screenshots/L04/
```

| File | Description |
|---|---|
| `01-license-state-redacted.png` | Initial tenant licence state |
| `02-security-defaults-state.png` | Security Defaults state before configuration |
| `03-authentication-methods-policy-before.png` | Authentication Methods policy inventory |
| `04-sspr-properties-before.png` | Initial SSPR state |
| `05-conditional-access-before.png` | Conditional Access availability before premium licensing |
| `06-p2-trial-active-redacted.png` | Active Microsoft Entra ID P2 trial |
| `07-pilot-group-members-redacted.png` | L04 pilot-group membership |
| `08-sspr-pilot-scope.png` | SSPR configured for the selected pilot group |
| `09-sspr-two-methods.png` | Two verification methods required |
| `10-sspr-registration-policy.png` | Registration and reconfirmation configuration |
| `11-ana-security-info-registered-redacted.png` | Ana’s registered security information |
| `12-ana-sspr-reset-success-redacted.png` | Successful SSPR completion |
| `13-ana-post-reset-sign-in-redacted.png` | Successful sign-in after the password reset |
| `14-andrei-non-pilot-sspr-denied-redacted.png` | Negative result for the non-pilot user |
| `15-ana-positive-sspr-reset-audit-log-redacted.png` | Successful SSPR audit-log event |
| `16-andrei-negative-sspr-reset-audit-log-redacted.png` | Failed SSPR audit-log event caused by group scope |

## Security and Privacy Controls

The following safety controls were applied:

- A dedicated pilot group limited the deployment scope.
- Administrative accounts were not used as normal test users.
- Emergency access accounts were excluded from the pilot.
- Security Defaults remained enabled.
- No enforced Conditional Access policy was introduced.
- Two verification methods were required for password reset.
- Password-reset notifications were enabled.
- The negative-control user was kept outside the SSPR group.
- Passwords were never recorded.
- QR codes were not captured.
- MFA codes and number-matching values were not captured.
- Phone numbers were not published.
- Full user principal names were redacted.
- Public IP addresses were redacted.
- Tenant, object and correlation identifiers were redacted where applicable.
- Recovery information was not published.

## Key Learning Points

The lab reinforced the following concepts:

- Authentication proves identity; authorization controls permitted actions.
- Registering Microsoft Authenticator does not automatically enforce MFA.
- Enabling an authentication method does not mean every user has registered it.
- Authentication Methods policy controls method availability.
- SSPR policy controls password-reset eligibility and proof requirements.
- Conditional Access controls when access requires MFA or another access control.
- Authentication strengths control which methods may satisfy a Conditional Access requirement.
- Combined registration provides one registration experience, but MFA and SSPR remain separate features.
- Cloud-only password reset requires appropriate licensing.
- A user can be licensed but remain ineligible because they are outside the selected SSPR group.
- Audit logs identify the operational reason for success or failure.
- Pilot deployment reduces the risk of broad configuration errors.
- Emergency access accounts must remain separate from normal testing.

## Final State

At the end of the lab:

- The Microsoft Entra ID P2 trial remained active.
- SSPR remained enabled for `grp-l04-mfa-sspr-pilot`.
- Ana remained the positive pilot user.
- Andrei remained outside the pilot group.
- Two reset-verification methods remained required.
- Security-information registration remained required.
- Security Defaults remained enabled.
- No Conditional Access policies were modified.
- Administrative and emergency access accounts remained outside the test scope.

The P2 trial and test-user licences were retained because later labs require premium Entra capabilities.

## Rollback

If rollback is required:

1. Confirm that an administrative session and the emergency access accounts remain usable.
2. Change the SSPR scope from `Selected` to its previous value.
3. Save the SSPR configuration.
4. Remove Ana from `grp-l04-mfa-sspr-pilot` if the group is no longer required.
5. Remove test-only authentication methods if they are no longer needed.
6. Remove test-user P2 assignments only if they are not needed by later labs.
7. Delete the pilot group only after confirming that no later lab depends on it.
8. Do not remove or modify emergency access accounts.
9. Review the audit logs to verify the rollback operations.
10. Preserve the evidence and documentation in the repository.

## Conclusion

L04 was completed successfully.

The lab demonstrated a controlled Microsoft Entra MFA-registration and SSPR deployment using premium licensing, selected-group targeting, two verification methods, positive and negative test cases, post-reset authentication validation, and audit-log investigation.

The successful Ana scenario confirmed that an eligible pilot user could reset a cloud-managed password and sign in afterward.

The failed Andrei scenario confirmed that a licensed user outside the selected SSPR group remained ineligible.

Together, these tests demonstrated both the intended functionality and enforcement boundary of the pilot deployment.