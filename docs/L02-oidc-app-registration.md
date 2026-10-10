# L02 — OIDC Application Registration and Local Sign-In

## Objective

Register a single-tenant OpenID Connect application in Microsoft Entra ID and implement a local Single-page Application using Authorization Code with PKCE.

## Application registration

- Application name: `entra-lab-oidc-app`
- Account type: Single tenant
- Platform: Single-page application
- Redirect URI: `http://localhost:3000/auth/callback`
- Implicit token issuance: disabled
- Client secret: not created
- Enterprise application: verified and activated

## API permissions

- API: Microsoft Graph
- Permission: `User.Read`
- Permission type: Delegated
- Additional permissions: none
- Admin consent: not granted

## Local application

- Framework: Vite Vanilla JavaScript
- Authentication library: `@azure/msal-browser`
- MSAL version: `5.22.0`
- Local URL: `http://localhost:3000`
- Authentication flow: Authorization Code with PKCE

## Implementation result

The application successfully:

1. Displayed a local sign-in page.
2. Redirected the user to Microsoft Entra ID.
3. Completed user authentication.
4. Displayed the permission-consent screen.
5. Returned to the local application.
6. Displayed the authenticated account.
7. Acquired an access token silently.
8. Called Microsoft Graph `/v1.0/me`.
9. Displayed the returned profile data.

## Security decisions

- The application is single-tenant.
- The SPA uses Authorization Code with PKCE.
- No client secret was created.
- Implicit token issuance remains disabled.
- Only the delegated `User.Read` permission was configured.
- Real environment values are stored in `.env.local`.
- `.env.local` is excluded from Git.
- Tokens, authorization codes, passwords and MFA data were not published.
- Screenshots were redacted before being added to the repository.

## Screenshots

- `screenshots/L02/01-app-registration-overview-redacted.png`
- `screenshots/L02/02-authentication-settings-redacted.png`
- `screenshots/L02/03-api-permissions-redacted.png`
- `screenshots/L02/04-enterprise-application-redacted.png`
- `screenshots/L02/05-local-app-before-login.png`
- `screenshots/L02/06-entra-sign-in-redacted.png`
- `screenshots/L02/07-entra-sign-in-app-permission-redacted.png`
- `screenshots/L02/08-oidc-login-success-redacted.png`
- `screenshots/L02/09-graph-user-read-redacted.png`

## Validation

- Production build: completed
- Local application startup: completed
- Microsoft Entra redirect: completed
- OIDC sign-in: completed
- Permission consent: completed
- Authenticated account display: completed
- Silent token acquisition: completed
- Microsoft Graph `/me` call: completed
- Profile display: completed

## Cleanup

- No Azure resources were created.
- No client secret was created.
- No excessive permissions were added.
- The App Registration is retained for future identity labs.

## Reproduce the local application

1. Create a single-tenant app registration and configure a SPA redirect URI of `http://localhost:3000/auth/callback`. Keep implicit token issuance disabled and do not create a client secret.
2. Configure only delegated Microsoft Graph `User.Read`. Consent requirements depend on the lab tenant's settings.
3. In `apps/l02-oidc-spa/`, copy `.env.example` to `.env.local` and fill in your own application client ID and tenant ID. Keep the redirect URI above.
4. Run `npm.cmd ci` on Windows to install the dependencies recorded in the lockfile. Use `npm ci` where the normal npm command is available.
5. Run `npm.cmd run dev -- --port 3000 --strictPort` and open `http://localhost:3000`.
6. Sign in with a lab user, read the profile through Microsoft Graph, and sign out after testing. Redact profile identifiers before sharing screenshots.
7. Use `npm.cmd run build` for a local build check. Do not publish generated `dist/` assets from a tenant-specific configuration.

The explicit port and `--strictPort` keep the local server consistent with the registered redirect URI. If port 3000 is occupied, free it rather than silently using another port.
