# L09 — Privileged Identity Management for Microsoft Entra Roles

**Status:** COMPLETED
**Completed:** 2026-10-04

## Objective

Demonstrate Microsoft Entra Privileged Identity Management (PIM) for a Microsoft Entra directory role by using a time-bound eligible assignment, just-in-time activation, MFA, justification, manual deactivation, and PIM audit evidence.

## Scope

- PIM area: Microsoft Entra roles
- Test user: Alex
- Test role: Security Reader
- Directory scope: Default Directory
- Azure resource roles were not modified
- Existing Conditional Access and MFA policies were not changed
- Emergency access accounts were not used

## Preconditions

- Required Microsoft Entra licensing was already available.
- Alex was an existing licensed test user.
- MFA was already configured for Alex.
- Existing Conditional Access policies from previous labs remained enabled.

## PIM Role Configuration

The **Security Reader** PIM role settings were configured as follows:

- Activation maximum duration: **1 hour**
- On activation require: **Azure MFA**
- Require justification on activation: **Yes**
- Require ticket information on activation: **No**
- Require approval to activate: **No**
- Approvers: **None**

The existing assignment settings and notification defaults were otherwise left unchanged.

## Eligible Assignment

Alex received a **time-bound eligible assignment** for the **Security Reader** role.

The assignment was created for approximately one day and was not configured as a permanent active assignment.

This demonstrated the difference between:

- **Eligible** — the user can request activation but does not continuously hold the role permissions.
- **Active** — the role permissions are currently active after a successful PIM activation.

## JIT Activation

Alex opened **Privileged Identity Management > My roles > Microsoft Entra roles** and activated the eligible **Security Reader** role.

The activation request used:

- Duration: **1 hour**
- MFA requirement: enabled by the PIM role policy
- Justification:

  `L09 PIM validation - temporary Security Reader access`

No approval workflow was required for this lab.

After activation, the **Security Reader** role appeared under Alex's **Active assignments** with state **Activated** and a one-hour end time.

## Deactivation and Observation

Alex manually deactivated the Security Reader role instead of leaving the privilege active for the full one-hour activation period.

Two early deactivation attempts failed while the activation was still inside the initial five-minute window. A later deactivation attempt succeeded.

The PIM Resource audit recorded:

- Creation of the eligible Security Reader assignment
- PIM activation request
- Successful PIM activation
- Two failed role-removal processing attempts
- Successful PIM deactivation request
- Successful PIM deactivation completion

The failed deactivation attempts were retained in the evidence because they are useful troubleshooting and audit data rather than being hidden.

## Validation

The lab validated that:

1. Alex could hold an **eligible** Security Reader assignment without continuous privileged access.
2. PIM required a controlled activation process before the role became active.
3. The activation was limited to a maximum of one hour.
4. MFA and justification requirements were part of the activation policy.
5. The role became active only after the PIM activation completed.
6. The active privilege could be manually deactivated when no longer required.
7. PIM Resource audit preserved both successful and failed privileged-access events.
8. Existing Conditional Access policies, emergency access accounts, and Azure resource roles were not modified.

## Evidence

Screenshots are stored in `screenshots/L09/`:

- `01-security-reader-pim-settings-redacted.png` — Security Reader PIM activation policy
- `02-alex-eligible-security-reader-redacted.png` — Alex time-bound eligible assignment
- `03-alex-activation-request-redacted.png` — One-hour activation request and justification
- `04-alex-security-reader-active-redacted.png` — Security Reader active through PIM
- `05-pim-audit-history-redacted.png` — Eligible assignment, activation, failed early deactivation attempts, and successful deactivation audit events

## Result

L09 successfully demonstrated the Microsoft Entra PIM lifecycle for a directory role:

**Eligible assignment → JIT activation → MFA and justification controls → temporary active privilege → manual deactivation → audit validation**

The lab used the low-risk **Security Reader** role and did not modify Azure resource-role PIM, which is reserved for L10.
