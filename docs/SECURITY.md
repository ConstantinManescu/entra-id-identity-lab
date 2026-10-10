# Lab and Publication Security

This repository documents a personal training tenant. The recorded controls do not establish a complete production security baseline.

## Before a change

- Verify the tenant identity, exact objects, and licenses.
- Keep a verified recovery path independent of the experiment.
- Inspect existing policies. Do not modify an employer's tenant.
- Keep protections active; L06 documents the lab's transition from Security Defaults to Conditional Access.
- Keep experimental identity scope explicit. Several completed lab policies targeted all resources while restricting the included test users; inspect both identity and resource scope before reproducing them.
- `report-only` is observation, not protection, and does not demonstrate enforcement.

## Placeholders versus secrets

Application/client IDs, object IDs, and tenant IDs are identifiers, not passwords. Public examples should still use placeholders for privacy and portability. Never commit passwords, access/refresh/ID tokens, OAuth authorization codes, client secret values, private keys, PFX/P12 files, session cookies, MFA/QR/recovery codes, or HAR files.

Public screenshots must not show real names or email addresses, the real tenant domain, residential IP addresses, or billing data. Keep the event and technical conclusion visible. Do not invent or alter a result to make the demonstration appear successful.

Store raw exports outside the repository, as in L15, or in an ignored `private/` directory. Anonymization is a separate review step; the export script does not perform it. `.gitignore` does not remove secrets already committed. Check both the current files and Git history. If a secret is published accidentally, revoke or rotate the credential; deleting it from the latest commit does not invalidate it.

## After a change

- Perform a positive test, a negative test, and record the observed log result.
- Check whether another policy or access path was affected.
- Record resources that remain active and the cleanup deadline.
- Remove only confirmed objects; never use destructive wildcard commands.
- Revalidate protections and recovery after rollback and after the trial.

References: [emergency access](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access), [Conditional Access planning](https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access).


## Historical state and publication

Lab final-state sections describe their recorded session checkpoints. Unconfirmed cleanup remains labelled as such. Reviewing this archive does not verify live tenant state.

Review historical image and text versions as well as the latest files before making an existing repository public. Identifier redaction in a later commit does not redact an older commit. Identifiers are not credentials, but can still reveal personal tenant or subscription information.
