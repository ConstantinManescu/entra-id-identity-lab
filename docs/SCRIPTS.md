# Microsoft Graph Export and Comparison

The retained script, `scripts/L15-GraphExportDiff.ps1`, contains the two PowerShell functions used in [L15](L15-graph-export-diff.md). It reads selected users, one assigned group and its direct members, then compares snapshots. It does not change directory configuration.

## Prerequisites

- PowerShell 7.
- Microsoft Graph PowerShell modules `Microsoft.Graph.Authentication`, `Microsoft.Graph.Users` and `Microsoft.Graph.Groups`.
- A delegated connection to the intended lab tenant with the read permissions used in L15: `User.Read.All` and `GroupMember.Read.All`, with any required consent.
- Private local paths for snapshot and comparison files, outside the public repository.

Authenticate explicitly to your lab tenant and confirm the context before collection. The export function requires an existing Graph context; it does not authenticate or independently verify that the connected tenant is the one you intended.

## Use

1. Dot-source `scripts/L15-GraphExportDiff.ps1` in PowerShell 7.
2. Set a local dictionary mapping test-user aliases to their real Object IDs, plus the exact Object ID of the dedicated L15 group. Do not commit those values.
3. Call `Export-L15Snapshot -UserIds $userIds -GroupId $groupId -OutputPath $baselinePath`.
4. Export a second snapshot to a different private path.
5. Call `Compare-L15Snapshot -ReferencePath $baselinePath -DifferencePath $secondPath -ReportPath $reportPath`.
6. Restore any controlled directory changes through the same administrative method used for the lab, export again and compare with the baseline.
7. Disconnect the Graph session after testing. Record separately whether delegated consent is retained or removed.

Use new output filenames. Exports refuse an existing snapshot path, but the comparison function does not currently refuse an existing report path. Keep reports separate from snapshots to avoid overwriting evidence.

## Data and limits

Raw snapshots include the tenant ID, user and group Object IDs, display names, departments, account-enabled states and membership IDs. Comparison reports can also contain identifying property values. Keep these files private and share only a reviewed summary.

The comparison checks tenant, group, user scope and aliases, and ignores collection timestamps when looking for configuration changes. Direct member collection uses `-All` for pagination. Unexpected group members stop export.

This is a selected-state comparison, not a full tenant backup, a restore tool or an effective-access assessment. It does not evaluate nested membership. Changes identify state differences; audit logs are needed to establish who changed an object and when.

The completed L15 report and four screenshots record the actual lab execution.
