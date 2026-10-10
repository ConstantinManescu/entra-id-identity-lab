# L10 - PIM for Azure resource roles

**Status:** COMPLETED - practical validation

**Completed:** 2026-10-05

**Cleanup:** Pending confirmation

## Objective

Validate just-in-time Azure RBAC access using Privileged Identity Management (PIM). Demonstrate that an eligible user can obtain temporary Contributor permissions at one resource-group scope after approval, while read-only access and scope boundaries remain enforced.

L09 covered Microsoft Entra directory roles. L10 applied the same eligibility and activation model to Azure resource roles, with emphasis on Azure RBAC scope, inherited permissions and automatic expiry.

## Environment and scope

- Microsoft Entra tenant with the required PIM licenses and MFA registered for the test users.
- Azure subscription administered through an account with the required Azure permissions.
- Target resource group: `rg-entra-l10-pim`.
- Control resource group: `rg-entra-l10-control`.
- Both resource groups were used without deploying VMs, storage accounts or other workload resources.
- Validation operation: update a resource-group tag.
- Target tag observed in the evidence: `PIM Test = activated-by-ana`.

## Accounts and access model

| Account | Lab access or responsibility |
| --- | --- |
| Administrator | Configure Azure RBAC and PIM; review audit evidence; perform cleanup |
| Ana Maria | Active Reader on both groups; eligible Contributor on the target group only |
| Alex | Active Reader on the target group; read-only control |
| Andrei | No lab Azure role; no-access control |
| Claudiu Auditor | Designated Contributor activation approver at the target scope |

Approver configuration did not grant Claudiu the Contributor role. Ana's Reader access was separate from her eligible Contributor assignment and remained available after activation expiry.

## PIM configuration

Contributor settings were configured specifically for `rg-entra-l10-pim`.

| Setting | Configured value |
| --- | --- |
| Maximum activation duration | 1 hour |
| MFA on activation | Required |
| Justification on activation | Required |
| Ticket information | Not required |
| Approval on activation | Required |
| Approver | Claudiu Auditor |
| Permanent eligible assignments | Not allowed |
| Maximum eligible assignment duration | 15 days |
| Permanent active assignments | Not allowed |
| Maximum active assignment duration | 15 days |

Ana received a direct eligible Contributor assignment from 2026-10-05 to 2026-10-06, approximately one day. The 15-day policy limit did not represent the duration of her activation: the activation lasted one hour.

## Execution

1. Prepared the target and control resource groups and the baseline Reader assignments.
2. Configured the target group's Contributor activation policy with MFA, justification and approval.
3. Assigned Ana time-limited eligible Contributor access at the target resource-group scope.
4. Validated the baseline access: Ana and Alex had read-only access; Andrei had no lab resource access.
5. Ana requested one hour of Contributor activation with this justification:

   > L10: validate temporary Contributor access by updating a resource-group tag.

6. Claudiu approved the initial activation request.
7. During the activation, Ana successfully updated the target group's tag to `PIM Test = activated-by-ana`.
8. Ana attempted a tag write on the control group. The operation failed, demonstrating the scope boundary.
9. Alex remained unable to modify the target group.
10. Allowed Ana's one-hour Contributor activation to expire automatically.
11. Retested a tag write on the target group after expiry. The operation failed while Reader access remained.
12. Reviewed the Azure Activity log for the successful tag write, automatic expiry and subsequent request denial.

## Separate request captured after expiry

The initial approver-interface screenshot was missed. After the successful activation expired, Ana submitted a second request with the reason `test` so that the approver interface could be captured.

Claudiu denied this second request. Screenshot 05 therefore shows the approver interface for a separate later request, not the approval of the original activation. The denial is visible in screenshot 09. This second request did not grant new Contributor access.

## Validation results

| Test | Result | Evidence basis |
| --- | --- | --- |
| Ana and Alex have target Reader assignments | PASS | Screenshot 01 |
| Contributor requires MFA, justification and approval | PASS | Screenshot 02 |
| Ana is eligible at the target scope | PASS | Screenshot 03 |
| Initial request uses a one-hour duration and justification | PASS | Screenshot 04 shows the prepared request |
| Initial activation approved | PASS | Observed during execution; original approval detail was not captured |
| Ana can update the target tag during activation | PASS | Screenshots 06 and 09 |
| Ana cannot write tags at the control scope | PASS | Observed during execution; screenshot 07 shows the failed operation |
| Alex remains read-only | PASS | Manual validation reported during execution |
| Andrei has no lab resource access | PASS | Manual validation reported during execution |
| Contributor activation expires automatically | PASS | Screenshot 09 records PIM activation expiry |
| Ana cannot write tags after expiry | PASS | Observed during execution; screenshot 08 shows the failed operation |
| Later activation request denied | PASS | Denial observed during execution and recorded in screenshot 09 |

## Screenshot evidence

Screenshots are stored directly in `screenshots/L10/`; no separate screenshot index is required.

| File | Description |
| --- | --- |
| `01-target-reader-assignments-redacted.png` | Ana and Alex have active Reader assignments at the target scope |
| `02-contributor-activation-settings-redacted.png` | Saved Contributor activation policy and designated approver |
| `03-ana-eligible-contributor-redacted.png` | Ana's direct time-limited eligible Contributor assignment |
| `04-ana-request-for-contributor-redacted.png` | Initial activation form with one-hour duration and justification |
| `05-claudiu-second-activation-request-redacted.png` | Claudiu's interface for the separate request submitted after expiry and subsequently denied |
| `06-ana-target-tag-update-success-redacted.png` | Saved target tag following Ana's successful write |
| `07-ana-control-scope-write-denied-redacted.png` | Failed tag write at the control resource-group scope |
| `08-ana-write-denied-after-expiry-redacted.png` | Failed tag write at the target scope after activation expiry |
| `09-ana-tag-write-activity-log-redacted.png` | Successful Write tags by Ana, automatic PIM expiry and later request denial |

## Evidence limits

- Screenshot 04 captures the activation form, not the submission outcome.
- Screenshot 05 captures the second request before its decision; screenshot 09 records its denial.
- The failure notifications in screenshots 07 and 08 do not display the underlying authorization error details. The access-denial conclusions also rely on the controlled test conditions and observed results.
- Screenshot 08 does not establish that the previously saved tag value remained unchanged.
- Screenshot 01 also shows a collapsed custom Network Reader assignment. Its member and permissions are not established by that image.
- Alex's and Andrei's negative tests were validated manually without additional screenshots.

## Cleanup checklist

Cleanup completion has not yet been confirmed. Update this section after performing and verifying the applicable actions.

- [ ] Remove Ana's eligible Contributor assignment from `rg-entra-l10-pim`.
- [ ] Verify Ana has no remaining active Contributor assignment at that scope.
- [ ] Disable the lab's Contributor approval requirement and remove Claudiu from its approver list.
- [ ] Remove the lab Reader assignments: Ana and Alex on the target group; Ana on the control group.
- [ ] Confirm both groups contain no workload resources and delete the two dedicated lab groups when no longer needed.

## Lessons learned

- Entra directory roles and Azure RBAC roles use different permission systems.
- Eligible access does not authorize resource modification until activation is approved and active.
- Azure role permissions are bounded by scope and inherit downward.
- PIM role settings are configured per role and scope; they do not inherit downward like Azure RBAC permissions.
- Activation expiry removes the temporary active assignment, while separate Reader access can remain.
- An approver can approve or deny a request without receiving the requested resource role.
- Audit history can substantiate a completed test even when an interface screenshot was missed.

## References

- [Assign Azure resource roles in PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-assign-roles)
- [Configure Azure resource role settings in PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-configure-role-settings)
- [Activate Azure resource roles in PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-activate-your-roles)
- [Approve Azure resource role requests in PIM](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-resource-roles-approval-workflow)
- [Understand Azure RBAC scope](https://learn.microsoft.com/en-us/azure/role-based-access-control/scope-overview)
