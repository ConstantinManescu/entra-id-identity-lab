# L07 - Conditional Access Controlled Block

**Status:** COMPLETED

**Completed:** 2026-10-03

## Objective

Deploy and validate a Conditional Access block policy for a small pilot group.
Compare report-only predictions with enforced results, confirm that control
users remain outside the policy scope, and restore pilot-user access through
a controlled rollback.

## Test scope

| User | Role |
|---|---|
| Ana Maria | Blocked pilot user |
| Claudiu Auditor | Blocked pilot user |
| Alex | Control user outside the block group |
| Andrei | Control user outside the block group |

Testing used Azure portal sign-ins in the lab tenant. No Azure resources were
created for this lab.

## Configuration

| Setting | Value |
|---|---|
| Security group | `grp-entra-l07-block-pilot` |
| Membership type | Assigned |
| Group members | Ana Maria and Claudiu Auditor |
| Policy | `CA-L07-Controlled-Block-Pilot` |
| Included identities | Dedicated pilot group only |
| Excluded identities | Main account, separate administrator, and both emergency access accounts |
| Target resources | All resources |
| Resource exclusions | None |
| Network conditions | Not configured |
| Additional conditions | None |
| Grant control | Block access |
| Session controls | None |
| Policy sequence | Report-only -> On -> Off |

Existing baseline MFA protection remained enabled. Emergency access accounts
were excluded from the block policy and were not used for live sign-in testing.

## Procedure

1. Established successful baseline sign-ins for all four test users.
2. Created the assigned security group containing Ana and Claudiu.
3. Created the block policy in Report-only with explicit protected-account exclusions.
4. Used What If to check pilot and non-pilot policy applicability.
5. Tested actual report-only sign-ins and inspected the policy results.
6. Enabled the policy and reproduced access denials for Ana and Claudiu.
7. Checked sign-in logs to identify the Lab 07 block policy.
8. Tested Alex and Andrei while the block policy was enabled.
9. Disabled the policy and repeated sign-ins for Ana and Claudiu.

## Validation results

| Test | Result |
|---|---|
| Baseline sign-ins | All four users showed Success |
| Ana report-only evaluation | Lab 07 showed Report-only: Failure |
| Alex report-only evaluation | Lab 07 showed Report-only: Not applied |
| Ana enforced test | Browser access denied; Lab 07 showed Block / Failure |
| Claudiu enforced test | Browser access denied; Lab 07 showed Block / Failure |
| Alex control test | Lab 07 showed Not applied; baseline MFA policy showed Success |
| Andrei control test | Lab 07 showed Not applied; baseline MFA policy showed Success |
| Rollback configuration | Lab 07 policy set to Off |
| Ana recovery test | Access restored; Lab 07 showed Disabled and baseline MFA showed Success |
| Claudiu recovery test | Access restored; Lab 07 showed Disabled and baseline MFA showed Success |

## Findings

- Report-only evaluation predicted the block without enforcing it.
- A matching enabled block policy denied access even with existing MFA protection.
- Users outside the pilot group were not affected by the Lab 07 policy.
- Sign-in policy results identified the configured block as a cause of denial.
- Disabling the policy restored pilot-user access while baseline MFA remained active.
- Baseline sign-in logs showed that MFA could be satisfied by an existing token claim.

## Final state and rollback

The Lab 07 policy is saved as **Off**. The pilot group still contains Ana and
Claudiu. Their access was restored after rollback. The policy and group were
retained for reference.

## Evidence

The 25 redacted screenshots are stored in `screenshots/L07/`.
Numbered filenames follow the configuration and test sequence. No separate
screenshot index was created.

## References

- [Conditional Access policy evaluation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policies)
- [Report-only mode and results](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-report-only)
- [Troubleshooting Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/troubleshoot-conditional-access)
