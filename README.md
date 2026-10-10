# Microsoft Entra ID Identity and Access Administration Lab

Hands-on Microsoft Entra ID labs covering identity administration, authentication, authorization, privileged access and access governance.

I built this project while moving from networking, VoIP and software testing toward Azure administration and cloud identity management. The reports record configurations, positive and negative tests, troubleshooting findings, evidence limits and cleanup observations from a personal lab tenant.

## Results

The revised sequence contains 19 labs, L00–L18: 18 completed within their documented scope and one blocked access-review application test. Practical completion does not imply that every retained tenant object has been removed.

| Lab | Topic | Result |
| --- | --- | --- |
| [L00](docs/L00-preflight.md) | Preflight, account separation and recovery | Completed |
| [L01](docs/L01-users-groups-roles.md) | Users, groups and directory roles | Completed |
| [L02](docs/L02-oidc-app-registration.md) | OIDC SPA, PKCE and Microsoft Graph profile access | Completed |
| [L03](docs/L03-saml-sso.md) | SAML SSO and direct application assignment | Completed |
| [L04](docs/L04-mfa-sspr.md) | MFA registration and self-service password reset | Completed |
| [L05](docs/L05-dynamic-group.md) | Dynamic user-group membership | Completed |
| [L06](docs/L06-ca-pilot-mfa.md) | Conditional Access MFA pilot and baseline protection | Completed |
| [L07](docs/L07-controlled-block.md) | Conditional Access controlled block and rollback | Completed |
| [L08](docs/L08-conditions-and-sessions.md) | Conditional Access conditions and session controls | Completed |
| [L09](docs/L09-pim-entra-roles.md) | PIM for Microsoft Entra directory roles | Completed |
| [L10](docs/L10-pim-azure-resource-roles.md) | PIM for Azure resource roles | Completed |
| [L11](docs/L11-identity-protection.md) | Identity Protection and administrative risk simulation | Completed |
| [L12](docs/L12-access-review.md) | Access reviews and unresolved result application | Blocked: result application remained Applying |
| [L13](docs/L13-access-package.md) | Access packages, approval and expiration | Completed |
| [L14](docs/L14-scim-provisioning.md) | SCIM provisioning, updates and deactivation | Completed |
| [L15](docs/L15-graph-export-diff.md) | Microsoft Graph export and snapshot comparison | Completed |
| [L16](docs/L16-troubleshooting.md) | Application assignment and Conditional Access troubleshooting | Completed |
| [L17](docs/L17-capstone-and-cleanup.md) | Scoped access capstone and cleanup | Completed |
| [L18](docs/L18-workload-identities-and-azure-rbac.md) | Managed identity and container-scoped Azure RBAC | Completed |

The optional devices and hybrid identity lab was skipped. Workload identity, originally planned as L19, is documented as L18 in the revised sequence.

## Selected demonstrations

- **Application access:** a local OIDC SPA using Authorization Code with PKCE and delegated Microsoft Graph `User.Read`; SAML application assignment with allowed and denied access.
- **Authentication controls:** selected-group SSPR, Conditional Access MFA, controlled blocking, sign-in frequency and browser persistence.
- **Privileged access:** eligible PIM assignments, directory-role activation and deactivation, and approved Azure Contributor activation with scope and expiry tests.
- **Governance and operations:** access-package delivery and expiration, SCIM creation/update/deactivation, Graph snapshots and drift detection, and access-failure diagnosis.
- **Workload authorization:** a VM system-assigned managed identity with successful blob read and denied write under container-scoped Storage Blob Data Reader access.

## Evidence and limitations

Each lab report points to its screenshots under `screenshots/Lxx/`. There is no separate screenshot index. [The tracker](progress/tracker.csv) records the status of every lab.

- **L12:** configuration and reviewer decisions were validated, but two reviews remained in `Applying`. Review-driven membership removal was not demonstrated, and a platform defect was not confirmed.
- **L11:** user risk was deliberately introduced by administrative confirmation. Sign-in-risk matching used What If; automated risky-sign-in detection and enforcement were not demonstrated.
- **L17:** Entra sign-in, application assignment, MFA satisfaction, membership removal and cleanup were tested. The SAML Toolkit encountered an application-side processing error during Andrei's positive test, so that attempt did not establish a usable Toolkit session.
- Several reports distinguish verified lab results from cleanup actions whose completion was not recorded. Historical final-state sections describe the end of their respective lab sessions, not a live inventory of the tenant.

## Repository layout

```text
README.md
apps/l02-oidc-spa/    Local authentication application source and dependency lockfile
docs/                Lab reports, script instructions, security notes and sources
progress/tracker.csv Lab status and evidence paths
screenshots/L00–L18/ Lab evidence
scripts/             Microsoft Graph export and comparison functions used in L15
```

## Run the local OIDC application

See [L02](docs/L02-oidc-app-registration.md) for registration settings and setup. Use a separate lab tenant, copy `.env.example` to a local `.env.local`, and set your own application and tenant identifiers. The SPA does not require a client secret.

See [script instructions](docs/SCRIPTS.md) for the L15 export functions. Raw snapshots contain identifiers and must remain private.

## Security and cost handling

The project uses test identities and scoped experiments. Passwords, tokens, MFA/QR/recovery codes, session data, client secrets and private keys are excluded from public material. Identifiers are replaced or masked for privacy and portability. See [security notes](docs/SECURITY.md).

Most labs used identity services without Azure workload deployments. Temporary Azure resources were used where required; L18 records deletion of its dedicated resource group. Cleanup and licensing observations are recorded per lab.

## Scope

This is a personal learning portfolio. It does not establish production experience or certification, and does not cover the complete SC-300 curriculum. [Official references](docs/SOURCES.md) support further study.
