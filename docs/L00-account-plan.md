# L00 — Account Plan

## Purpose

Separate daily, administrative, testing and emergency access activities in Microsoft Entra ID.

## Original personal account at preflight

- Type: regular user account
- Current role: Global Administrator
- Usage at preflight: personal activities and administrative access
- Limitation: the original personal account still held Global Administrator; creating a separate administrator did not by itself remove that role
- MFA: configured
- Status: active

## Administrative account

- Alias: `entra-admin-01`
- Type: cloud-only administrative account
- Display name: Entra Lab Administrator 01
- Usage: Microsoft Entra administrative changes
- Role: Global Administrator
- MFA: configured and verified
- License: not assigned
- Daily usage: prohibited
- Status: created and verified

## Test users

- Initial test-user inventory: 3; the later lab sequence used a four-user test pool
- Usage: MFA, Conditional Access, groups, access reviews and troubleshooting
- Test-user aliases may appear in reports; full addresses and personal identifiers are excluded from public material

## Emergency access accounts

- Account 1: `breakglass-01`
- Account 2: `breakglass-02`
- Type: cloud-only
- Role: Global Administrator
- Usage: recovery of administrative access
- Normal usage: prohibited
- MFA: configured and verified for both accounts
- Licenses: not assigned
- Passwords and MFA recovery codes: stored outside the repository
- Status: both accounts created and verified

## Security rules

- Do not store passwords in the repository.
- Do not store MFA codes or recovery codes in the repository.
- Do not publish Tenant IDs, Subscription IDs or personal data.
- Do not use emergency access accounts for normal testing.
- Do not use Azure resources without checking potential costs first.
- Review emergency account sign-in activity periodically.

## Status

- Plan documented: completed
- Local inventory: completed
- Tenant identified: completed
- Separate administrative account: created and verified
- Emergency access accounts: two created and verified
- MFA: configured
- Trials at this checkpoint: not activated; P2 activation is documented in L04
- L00 status: COMPLETED

## Historical scope

This is the account plan recorded during L00. Later test users and licensing are documented in the corresponding reports. It does not certify current role assignments or a production-ready administrative separation.
