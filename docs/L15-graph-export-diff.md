# L15 — Microsoft Graph Export and Diff

**Status:** COMPLETED

**Completed:** 2026-10-09

## Objective

Export selected Microsoft Entra ID user properties and direct group
membership through Microsoft Graph, compare snapshots, detect controlled
changes, and verify restoration of the baseline.

## Scope

- Test users: Ana, Alex, Claudiu, and Andrei.
- Dedicated assigned security group: `grp-l15-graph-diff-pilot`.
- PowerShell 7 and Microsoft Graph PowerShell SDK.
- Export permissions requested: `User.Read.All` and `GroupMember.Read.All`.
- Controlled changes performed in Microsoft Entra admin center.
- Script: `scripts/L15-GraphExportDiff.ps1`.

The dedicated group kept this exercise independent of the ongoing L12
access review and existing lab groups.

## Export and Comparison Design

The export captures user Object IDs, local aliases, display names,
departments, account-enabled states, group properties, and direct member IDs.

User properties are explicitly requested. Group membership collection uses
`-All` to retrieve all pages.

Snapshots are compared using Object IDs. Collection timestamps are excluded
from the configuration comparison. The comparison checks that the tenant,
group, user scope, and aliases are consistent.

Graph request failures stop collection. Existing snapshot files are not
overwritten. Unexpected group members cause the export to stop.

## Validation Results

| Test | Expected result | Observed result |
|---|---|---|
| Baseline export | Four enabled users; Ana and Alex are members | PASS |
| Unchanged comparison | Zero differences | PASS — 0 changes |
| Controlled changes | Description changed; Alex removed; Claudiu added | PASS — 3 changes |
| Restored comparison | Original description and membership; zero differences | PASS — 0 changes |

Baseline group description:

`L15 baseline - Graph export and diff`

Changed group description:

`L15 changed - Graph export and diff`

Ana remained a member throughout. Andrei remained outside the group.
No user profile properties were changed during the controlled test.

## Evidence

- `../screenshots/L15/01-baseline-export-redacted.png`
- `../screenshots/L15/02-unchanged-comparison-redacted.png`
- `../screenshots/L15/03-controlled-changes-detected-redacted.png`
- `../screenshots/L15/04-restored-baseline-verified-redacted.png`

## Data Handling

Raw snapshots and comparison reports were stored outside the repository
under `D:\Azure\L15-private`.

Public evidence displays test-user aliases and selected results without
tenant IDs, user Object IDs, credentials, or authentication tokens.

## Restoration

The original group description was restored. Claudiu was removed and Alex
was added again, returning membership to Ana and Alex.

The final comparison found zero differences in the exported properties and
direct memberships. The restored group remains available for final cleanup.

## Limitations

This is a selected-data export and comparison, not a full tenant backup.

It compares the selected user and group properties and direct membership.
It does not evaluate nested membership, effective access, or all tenant
configuration.

A difference identifies changed state between snapshots. Audit logs are
needed to investigate the actor and exact event time.

## Outcome

The lab demonstrated repeatable Graph exports, an unchanged control,
detection of three controlled changes, and verified baseline restoration.
