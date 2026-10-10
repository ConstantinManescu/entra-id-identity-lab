#requires -Version 7.0

function Export-L15Snapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$UserIds,

        [Parameter(Mandatory)]
        [string]$GroupId,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $ErrorActionPreference = 'Stop'
    $context = Get-MgContext

    if (-not $context) {
        throw 'Connect to Microsoft Graph before exporting.'
    }

    if (Test-Path -LiteralPath $OutputPath) {
        throw "Snapshot already exists: $OutputPath. Use a new filename."
    }

    $startedUtc = [datetime]::UtcNow.ToString('o')

    $users = @(
        foreach ($alias in $UserIds.Keys) {
            $user = Get-MgUser `
                -UserId $UserIds[$alias] `
                -Property 'id', 'displayName', 'department', 'accountEnabled' `
                -ErrorAction Stop

            if (-not $user.Id -or $null -eq $user.AccountEnabled) {
                throw "Incomplete user data returned for $alias."
            }

            [pscustomobject][ordered]@{
                Id             = $user.Id
                Alias          = [string]$alias
                DisplayName    = $user.DisplayName
                Department     = $user.Department
                AccountEnabled = $user.AccountEnabled
            }
        }
    ) | Sort-Object Id

    $group = Get-MgGroup `
        -GroupId $GroupId `
        -Property 'id', 'displayName', 'description' `
        -ErrorAction Stop

    if (-not $group.Id) {
        throw 'Incomplete group data returned.'
    }

    $members = @(
        Get-MgGroupMember `
            -GroupId $GroupId `
            -All `
            -ErrorAction Stop
    )

    $knownIds = @($UserIds.Values)

    foreach ($member in $members) {
        if (-not $member.Id -or $member.Id -notin $knownIds) {
            throw 'The L15 group contains an unexpected member. Inspect it.'
        }
    }

    $memberIds = @(
        $members |
            Select-Object -ExpandProperty Id |
            Sort-Object -Unique
    )

    $snapshot = [pscustomobject][ordered]@{
        SchemaVersion = 1
        TenantId      = $context.TenantId
        StartedUtc    = $startedUtc
        CompletedUtc  = [datetime]::UtcNow.ToString('o')
        Users         = @($users)
        Group         = [pscustomobject][ordered]@{
            Id          = $group.Id
            DisplayName = $group.DisplayName
            Description = $group.Description
        }
        MemberIds     = $memberIds
    }

    $snapshot |
        ConvertTo-Json -Depth 6 |
        Set-Content -LiteralPath $OutputPath -Encoding utf8 -ErrorAction Stop

    Write-Host 'Snapshot saved successfully.'
    Write-Host "Users exported: $(@($users).Count)"
    Write-Host "Group: $($group.DisplayName)"
    Write-Host "Description: $($group.Description)"
    Write-Host "Direct members: $($memberIds.Count)"

    $users |
        Select-Object Alias, AccountEnabled,
            @{Name = 'InL15Group'; Expression = { $_.Id -in $memberIds }} |
        Sort-Object Alias |
        Format-Table -AutoSize
}

function Compare-L15Snapshot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ReferencePath,

        [Parameter(Mandatory)]
        [string]$DifferencePath,

        [Parameter(Mandatory)]
        [string]$ReportPath
    )

    $ErrorActionPreference = 'Stop'

    $before = Get-Content -LiteralPath $ReferencePath -Raw |
        ConvertFrom-Json

    $after = Get-Content -LiteralPath $DifferencePath -Raw |
        ConvertFrom-Json

    if ($before.SchemaVersion -ne 1 -or $after.SchemaVersion -ne 1) {
        throw 'Unsupported snapshot schema.'
    }

    if ($before.TenantId -ne $after.TenantId) {
        throw 'The snapshots belong to different tenants.'
    }

    if ($before.Group.Id -ne $after.Group.Id) {
        throw 'The snapshots refer to different groups.'
    }

    $beforeIds = @($before.Users.Id | Sort-Object)
    $afterIds = @($after.Users.Id | Sort-Object)

    if (($beforeIds -join '|') -ne ($afterIds -join '|')) {
        throw 'The user scope differs. Do not compare these snapshots.'
    }

    $changes = [System.Collections.Generic.List[object]]::new()

    foreach ($oldUser in $before.Users) {
        $newUser = $after.Users |
            Where-Object Id -EQ $oldUser.Id

        if ($oldUser.Alias -cne $newUser.Alias) {
            throw 'User aliases differ between snapshots.'
        }

        foreach ($property in 'DisplayName', 'Department', 'AccountEnabled') {
            if ($oldUser.$property -cne $newUser.$property) {
                $changes.Add([pscustomobject][ordered]@{
                    Change   = 'PropertyChanged'
                    Object   = $oldUser.Alias
                    Property = $property
                    Before   = $oldUser.$property
                    After    = $newUser.$property
                })
            }
        }
    }

    foreach ($property in 'DisplayName', 'Description') {
        if ($before.Group.$property -cne $after.Group.$property) {
            $changes.Add([pscustomobject][ordered]@{
                Change   = 'PropertyChanged'
                Object   = 'L15 group'
                Property = $property
                Before   = $before.Group.$property
                After    = $after.Group.$property
            })
        }
    }

    foreach ($user in $before.Users) {
        $wasMember = $user.Id -in @($before.MemberIds)
        $isMember = $user.Id -in @($after.MemberIds)

        if ($wasMember -ne $isMember) {
            $changes.Add([pscustomobject][ordered]@{
                Change   = if ($isMember) {
                    'MemberAdded'
                } else {
                    'MemberRemoved'
                }
                Object   = $user.Alias
                Property = 'DirectMembership'
                Before   = $wasMember
                After    = $isMember
            })
        }
    }

    $report = [pscustomobject][ordered]@{
        ComparedUtc = [datetime]::UtcNow.ToString('o')
        ChangeCount = $changes.Count
        Changes     = @($changes.ToArray())
    }

    $report |
        ConvertTo-Json -Depth 5 |
        Set-Content -LiteralPath $ReportPath -Encoding utf8 -ErrorAction Stop

    Write-Host "Changes detected: $($changes.Count)"

    if ($changes.Count -eq 0) {
        Write-Host 'PASS: No differences in the exported properties or memberships.'
    } else {
        $changes.ToArray() | Format-List
    }
}