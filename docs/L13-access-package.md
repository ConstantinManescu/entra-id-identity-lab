# L13 - Access Packages and Entitlement Management

**Status:** COMPLETED

**Completed:** 2026-10-09

## Objective

Configure an internal access package that grants temporary security-group membership through requests and approval. Validate delivery, rejection, manual revocation and automated removal after a short assignment lifetime.

The L13 groups were separate from the L12 access-review group. Completion of L12 was not a dependency.

## Environment

- Existing Microsoft Entra ID P2 trial and licensed internal test users.
- Administration through Microsoft Entra admin center.
- Requests through My Access.
- One security-group resource with its Member role.
- No additional Azure compute, storage or networking resources were created for this lab.

## Configuration

| Object or setting | Configuration |
| --- | --- |
| Catalog | `cat-l13-training` |
| Requester group | `grp-l13-requesters`, containing Ana and Alex |
| Resource group | `grp-l13-resource-access` |
| Access package | `ap-l13-project-access` |
| Assignment policy | `Initial Policy` |
| Resource role | Member of the resource group |
| Request scope | Specific users and groups: the requester group |
| Self requests | Enabled |
| Admin requests | Mandatory option retained by the portal |
| Approval | Required; Claudiu Auditor selected as approver |
| Decision deadline | One day |
| Assignment lifetime | Number of hours: one hour |

The resource group is a Microsoft Entra security group, rather than an Azure resource group.

Configuration evidence:

- [Requester-group membership](../screenshots/L13/01-requester-group-members-redacted.png)
- [Resource and Member role](../screenshots/L13/02-access-package-resource-role-redacted.png)
- [Request scope and Self option](../screenshots/L13/03-policy-request-scope-redacted.png)
- [Approval settings](../screenshots/L13/04-policy-approval-settings-redacted.png)
- [Lifecycle settings](../screenshots/L13/05-policy-lifecycle-settings-redacted.png)

The first assignment's recorded grant time and displayed end time also corroborate the one-hour duration.

## Accounts

| Account | Responsibility |
| --- | --- |
| Administrative account | Configure the package, inspect results and remove the first assignment |
| Ana Maria | Submit approved requests and test both removal paths |
| Alex | Submit a request that is intentionally denied |
| Andrei | Test discoverability outside the requester scope |
| Claudiu Auditor | Selected approver in the policy |

Requester-group membership defines eligibility to request. Resource-group membership is granted through a delivered assignment.

## Tests and results

| Test | Observed result | Evidence |
| --- | --- | --- |
| Ana requests access | My Access shows Pending approval | [06 - Pending request](../screenshots/L13/06-ana-request-pending-approval-redacted.png) |
| Ana receives access | The assignment shows Delivered with an end date; Ana is the resource group's only member | [07 - Delivered assignment](../screenshots/L13/07-ana-assignment-delivered-redacted.png), [08 - Membership](../screenshots/L13/08-resource-group-ana-member-redacted.png) |
| Administrator removes the first assignment | The resource group becomes empty; audit logs record administrator and resource removal | [09 - After removal](../screenshots/L13/09-resource-group-empty-after-removal-redacted.png), [14 - Audit trail](../screenshots/L13/14-entitlement-management-audit-events-redacted.png) |
| Alex requests access | My Access shows Denied; the audit trail includes a denial event | [10 - Denied request](../screenshots/L13/10-alex-request-denied-redacted.png), [14 - Audit trail](../screenshots/L13/14-entitlement-management-audit-events-redacted.png) |
| Andrei opens My Access | Available (0) and No access packages available are shown | [11 - Out-of-scope discovery](../screenshots/L13/11-andrei-request-not-allowed-redacted.png) |
| Ana's second assignment ends | Request history shows a later Removed operation requested by Azure AD; resource membership is removed and audit logs record system removal | [12 - System removal history](../screenshots/L13/12-ana-assignment-expired-redacted.png), [13 - Empty group](../screenshots/L13/13-resource-group-empty-after-expiry-redacted.png), [14 - Audit trail](../screenshots/L13/14-entitlement-management-audit-events-redacted.png) |

## Timeline

Times are those displayed on 9 October 2026. My Access labels its times as EEST; the audit view is set to Local.

| Time | Event |
| --- | --- |
| 11:33 AM | Ana's first request is submitted |
| Around 11:37 AM | First assignment fulfilled; displayed end time is 12:37:13 PM |
| Around 11:40 AM | Administrator removes the first assignment |
| Around 11:41 AM | Ana submits a second request |
| Around 11:42 AM | Second request approved and resource assignment fulfilled |
| Around 11:44 AM | Alex's request denied |
| Around 12:50 PM | System-initiated assignment and resource removal recorded |

The later system removal, following the second grant and the one-hour lifetime, is consistent with automatic expiration processing. Removal was observed after the nominal lifetime rather than exactly at its end.

## Evidence limits and observations

- Screenshot 11 demonstrates an empty available-package list for Andrei. It does not capture a direct-link request attempt or an explicit eligibility-error message.
- Despite its filename, screenshot 12 shows request history with a system-initiated Removed operation. It does not show an assignment filtered by the Expired status.
- The automated-expiration conclusion comes from correlating the lifecycle configuration, grant and removal times, system initiation, audit events and final empty group.
- Historical Delivered request entries record earlier successful grant operations. Current access must be checked through assignments and resource membership.
- Ana initially saw an empty package list. Later evidence shows Self enabled and a successful request. The original visibility issue was not conclusively isolated in the captured evidence.

Manual removal and automated removal used separate assignments, keeping the two tests distinct.

## Final state and cleanup

The last captured resource-group view contains zero members. The evidence does not establish whether Self requests were subsequently disabled or the lab objects deleted.

To close the configuration:

1. Confirm that the package has no active assignments.
2. Disable Self requests in the policy and save.
3. Retain the package, catalog and groups while reviewing documentation.
4. When no longer needed, delete the package, remove the catalog resource if required, delete the unused catalog and delete the two L13 groups.
5. Keep the L12 access-review group separate from this cleanup.

## Lessons learned

- Request eligibility and resource access are separate.
- Approval precedes technical delivery.
- Resource membership verifies the practical access change.
- Request history, current assignments and audit logs serve different purposes.
- Expiration conclusions should be supported by timing and actual access removal.

## References

- [Create an access package](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-package-create)
- [Access package visibility](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-package-visibility)
- [View, add and remove assignments](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-access-package-assignments)
- [Reports and audit logs](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-reports)
