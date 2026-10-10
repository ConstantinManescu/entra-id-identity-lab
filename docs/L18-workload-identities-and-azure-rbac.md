# L18 — Workload identities and Azure RBAC

**Status:** COMPLETED

**Completed:** 2026-10-11

**Lab sessions:** 2026-10-10 to 2026-10-11

## Objective

Use a system-assigned managed identity to access a private Azure blob without storing application credentials. Validate denied access before authorization, successful read access after a container-scoped role assignment, and denied write access with read-only permissions.

This lab covers the workload identity topic originally planned as L19. It is numbered L18 in the revised learning sequence. Devices and hybrid identity remain deferred.

## Environment and resources

| Component | Lab configuration |
| --- | --- |
| Resource group | `rg-l18-workload-identity` |
| Workload host | Linux VM `vm-l18-workload` |
| Identity | System-assigned managed identity |
| Storage account | `stl18cm` |
| Private blob container | `l18-data` |
| Existing test blob | `l18-test.txt` |
| Attempted write target | `l18-write-test.txt` |
| Workload role | Storage Blob Data Reader |
| Role assignment scope | Container `l18-data` |
| Execution method | Azure VM Run Command / RunShellScript |
| Test implementation | Python standard library with managed identity token acquisition and Blob REST requests |

The lab used temporary Azure resources. Entra P2 test users were not involved, and premium Entra licensing was not required for managed identity authentication.

## Identity and authorization model

Enabling the system-assigned identity created a managed identity service principal in the Microsoft Entra tenant. Azure associated the identity with the VM and managed its credentials.

The Python script requested an access token for Azure Storage from the VM metadata endpoint. It compared the token's `oid` claim with the expected VM principal ID before sending requests. This claim comparison was a diagnostic identity check, not cryptographic token validation. Azure Storage performed token validation and authorization.

The responsibilities were distinct:

- Microsoft Entra ID provided the workload identity and issued its access token.
- Azure managed the identity's association with the VM and its credentials.
- Azure RBAC defined the identity's permitted operations and scope.
- Azure Storage enforced access to the blob data.

The administrator launched Run Command, but the script's Storage requests used the VM's managed identity rather than the administrator's identity. No application client secret, storage account key, or SAS token was used for those test requests. Raw access tokens were not displayed in the output.

## Procedure

1. Created a dedicated resource group and storage account for the lab.
2. Created the private container `l18-data` and uploaded `l18-test.txt` using administrative preparation access.
3. Created a temporary Linux VM and enabled its system-assigned managed identity.
4. Ran the baseline test inside the VM before assigning the identity a blob-data role.
5. Confirmed token acquisition and an identity match, followed by a denied blob read.
6. Assigned Storage Blob Data Reader directly to the VM identity at container scope.
7. Ran the authorized test after allowing the permission change to propagate.
8. Confirmed a successful read and a denied write under the same identity.
9. Deleted the dedicated resource group after capturing evidence.

## Validation results

| Test | Observed result | Outcome |
| --- | --- | --- |
| System-assigned identity enabled | VM Identity page showed Status On | PASS |
| Baseline authentication | Managed identity token acquired; expected VM principal matched | PASS |
| Baseline blob read without permission | HTTP 403; `AuthorizationPermissionMismatch` | PASS |
| Role assignment | VM identity received Storage Blob Data Reader with scope shown as This resource on the container IAM page | PASS |
| Authorized authentication | Managed identity token acquired; expected VM principal matched | PASS |
| Authorized blob read | HTTP 200; returned `L18 managed identity read test.` | PASS |
| Write attempt with read-only access | HTTP 403; `AuthorizationPermissionMismatch` | PASS |
| Cleanup | Successful resource-group deletion notification and no matching resource group in the filtered list | PASS |

### Baseline output

```text
PHASE: baseline
Authentication: managed identity token acquired
Expected VM principal: MATCH
Raw token: not displayed
READ HTTP status: 403
READ service error: AuthorizationPermissionMismatch
BASELINE: PASS - authenticated identity lacks read permission
```

### Authorized output

```text
PHASE: authorized
Authentication: managed identity token acquired
Expected VM principal: MATCH
Raw token: not displayed
READ HTTP status: 200
READ TEST: PASS
Blob content: L18 managed identity read test.
WRITE HTTP status: 403
WRITE service error: AuthorizationPermissionMismatch
WRITE TEST: PASS - read-only identity cannot write
```

## Reproduction limit

The original Python access-test script and infrastructure deployment source were not retained in this archive. This report records the procedure and captured results, but does not provide a runnable deployment or the complete original test implementation.

## Troubleshooting findings

### Broken string literal

The initial script failed to parse because the write-test byte string contained an unintended line break. Python parsed the complete script before executing it, so no authentication or storage test occurred during that attempt.

The write payload was corrected to a single-line byte string:

```python
data=b"L18 write permission test."
```

### Placeholder validation rejected configured values

Replacing placeholder text throughout the script also changed the placeholder-check conditions to compare against the actual configured values. Those conditions then rejected the valid configuration.

The two obsolete placeholder-check blocks were removed. The runtime comparison between the token's identity claim and the expected VM principal was retained.

### Baseline mode retained after authorization

After the role assignment, a run still used `PHASE = "baseline"`. The read returned HTTP 200, but the baseline logic expected a denial and reported an unexpected result.

Changing the phase to `authorized` enabled the intended successful-read and denied-write tests. No broader role was needed.

### Run Command status versus test outcome

The portal's `Enable succeeded` message did not establish that the Python script or access tests succeeded. Validation relied on the script's stdout and stderr, HTTP results, and service error codes.

## Evidence

- [01-vm-system-assigned-identity-redacted.png](../screenshots/L18/01-vm-system-assigned-identity-redacted.png) — System-assigned identity enabled on the VM; principal ID redacted.
- [02-managed-identity-read-denied-redacted.png](../screenshots/L18/02-managed-identity-read-denied-redacted.png) — Baseline identity match and denied read.
- [03-container-blob-data-reader-assignment-redacted.png](../screenshots/L18/03-container-blob-data-reader-assignment-redacted.png) — Read-only role assigned to the VM identity at container scope.
- [04-managed-identity-read-success-write-denied-redacted.png](../screenshots/L18/04-managed-identity-read-success-write-denied-redacted.png) — Successful read and denied write under the managed identity.
- [05-resource-group-cleanup-redacted.png](../screenshots/L18/05-resource-group-cleanup-redacted.png) — Successful deletion of the lab resource group.

## Cleanup

The dedicated resource group `rg-l18-workload-identity` was deleted. The cleanup screenshot shows the completed deletion notification and no resource groups matching the lab filter.

Deleting the VM also deletes its system-assigned managed identity as part of its lifecycle. No additional resource deployment was performed to capture the identity in the Entra admin center after cleanup.

The lab did not require changes to existing Conditional Access policies or the four P2 test users.

## Lessons learned

- A workload can authenticate successfully while lacking permission for the requested operation.
- Managed identities connect Azure resource workloads to Microsoft Entra authentication without manually managed application credentials.
- Workload role assignments use the same principal, role, and scope model as Azure user role assignments.
- Storage Blob Data Reader permits reading blob data but does not grant write access.
- A container-scoped assignment avoids granting access across the whole storage account or subscription.
- Running a script through an administrator's session does not determine the identity used by every request inside the script.
- Test phase, identity, HTTP status, and service error details must be interpreted together.

## References

- [Managed identities for Azure resources](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview)
- [Use a VM managed identity to acquire an access token](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-use-vm-token)
- [Authorize access to blobs using Microsoft Entra ID](https://learn.microsoft.com/en-us/azure/storage/blobs/authorize-access-azure-active-directory)
- [Assign an Azure role for access to blob data](https://learn.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access)
- [Run scripts in a Linux VM using Run Command](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/run-command)
