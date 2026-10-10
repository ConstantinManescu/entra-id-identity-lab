# L03 — SAML SSO and Assigned Access

## Status

Completed.

## Objective

Configure and validate SAML-based single sign-on with Microsoft Entra ID using the Microsoft Entra SAML Toolkit. The lab demonstrates:

- Microsoft Entra ID acting as the Identity Provider (IdP).
- The SAML Toolkit acting as the Service Provider (SP).
- SAML Entity ID, Sign-on URL, and ACS/Reply URL configuration.
- SAML claims and signing certificate usage.
- Direct user assignment to an enterprise application.
- Successful access for an assigned user.
- Denied access for an unassigned user.

## Scenario

The lab uses a separate Enterprise Application named `Microsoft Entra SAML Toolkit`. The existing L02 OIDC application was not modified.

The test identities were:

- `Ana Maria` — directly assigned to the SAML enterprise application.
- `Claudiu Auditor` — not assigned to the SAML enterprise application.

The existing security group `grp-entra-lab-users` was not assigned to the SAML application. This kept the test focused on direct user assignment.

## Concepts demonstrated

### Identity Provider and Service Provider

Microsoft Entra ID acted as the Identity Provider. It authenticated the user and produced a signed SAML response.

The Microsoft Entra SAML Toolkit acted as the Service Provider. It received the SAML response at its Assertion Consumer Service endpoint, validated the response, and created an application session.

### SAML configuration values

The final Toolkit configuration used the following values:

```text
Entity ID:
https://samltoolkit.azurewebsites.net

Sign-on URL:
https://samltoolkit.azurewebsites.net/SAML/Login/22515

Reply URL / ACS URL:
https://samltoolkit.azurewebsites.net/SAML/Consume/22515
```

The numeric suffix identifies the Toolkit SAML configuration/connection. It is not a password, client secret, tenant ID, or user identifier. The same SSO configuration can be used by assigned users. The account that created the Toolkit-side configuration manages it from the Toolkit interface.

### Claims

The default claim mappings included:

```text
givenname                 user.givenname
surname                   user.surname
emailaddress              user.mail
name                      user.userprincipalname
Unique User Identifier    user.userprincipalname
```

The Toolkit requires a NameID in email-address format so that the application can associate the incoming SAML identity with its application-side user account.

### Signing certificate

Microsoft Entra generated an active SAML token-signing certificate. The raw public certificate was used by the Toolkit to validate SAML responses.

No private key, password, client secret, or raw SAML response was stored in the repository.

## Configuration performed

1. Added `Microsoft Entra SAML Toolkit` from the Microsoft Entra application gallery.
2. Opened the Enterprise Application and selected `Single sign-on`.
3. Selected `SAML` as the SSO method.
4. Initially entered the generic Toolkit values for the Entity ID, Reply URL, and Sign-on URL.
5. Registered a matching Toolkit-side account for the test user.
6. Created the Toolkit-side SAML configuration.
7. The Toolkit generated the configuration-specific `/22515` Sign-on and ACS URLs.
8. Updated the Entra Basic SAML Configuration with the generated URLs.
9. Confirmed that `Assignment required` was enabled.
10. Assigned `Ana Maria` directly under `Users and groups`.
11. Left `Claudiu Auditor` unassigned.

## Important troubleshooting lesson

The first SAML test did not produce the expected SSO behavior because the Entra configuration still used the generic Toolkit endpoints:

```text
https://samltoolkit.azurewebsites.net/
https://samltoolkit.azurewebsites.net/SAML/Consume
```

After the Toolkit-side SAML configuration was created, the final endpoints included the configuration identifier:

```text
https://samltoolkit.azurewebsites.net/SAML/Login/22515
https://samltoolkit.azurewebsites.net/SAML/Consume/22515
```

The configuration was corrected by copying the generated Sign-on URL and ACS URL into Entra. The Entity ID remained unchanged.

This demonstrated that the Service Provider's actual endpoints must match the values configured in the Identity Provider.

## Validation results

| Test | User | Assignment | Expected result | Observed result |
|---|---|---:|---|---|
| Positive SAML login | Ana Maria | Directly assigned | Access allowed | Passed |
| Negative assignment test | Claudiu Auditor | Not assigned | Access denied | Passed |

### Positive test

The SP-initiated URL was opened in a clean browser session:

```text
https://samltoolkit.azurewebsites.net/SAML/Login/22515
```

Microsoft Entra authenticated Ana Maria and returned a signed SAML response to the Toolkit ACS endpoint. The Toolkit then displayed Ana's authenticated session.

### Negative test

Claudiu Auditor attempted to access the same application while `Assignment required` was enabled. Microsoft Entra blocked access before the user reached the Toolkit.

Observed error:

```text
AADSTS50105
```

The error confirmed that the user was not directly assigned and was not a member of a group assigned to the application.

## Evidence

```text
screenshots/L03/01-enterprise-application-overview-redacted.png
screenshots/L03/02-basic-saml-configuration-redacted.png
screenshots/L03/03-direct-user-assignment-redacted.png
screenshots/L03/04-saml-toolkit-user-registered-redacted.png
screenshots/L03/05-saml-toolkit-configuration-redacted.png
screenshots/L03/06-saml-login-success-redacted.png
screenshots/L03/07-unassigned-user-denied-redacted.png
```

`04-saml-toolkit-user-registered-redacted.png` documents the Toolkit-side registered user/session state; `06-saml-login-success-redacted.png` documents the completed SP-initiated SAML login.

The retained Basic SAML Configuration screenshot shows the earlier generic endpoint settings; screenshot 05 shows the generated Toolkit connection URLs. The final values above describe the corrected configuration. The landing-page captures show a Toolkit session but do not independently establish the authentication protocol; the SP-initiated flow description also relies on the recorded execution.

Screenshots were redacted before publication. Raw request identifiers, correlation identifiers, full email addresses, tenant identifiers, passwords, certificates containing private material, and raw SAML responses were excluded.

## Cost and safety notes

- No Azure subscription resources or billable compute were created for this lab.
- The lab used Microsoft Entra ID and the Microsoft-hosted SAML Toolkit.
- Emergency access accounts and the Global Administrator account were not used for the positive or negative application-access tests.
- The OIDC application from L02 remains separate and unchanged.

## Rollback

To roll back the lab configuration:

1. Remove the direct assignment for `Ana Maria`.
2. Optionally disable or delete the SAML Toolkit Enterprise Application after the evidence and documentation are committed.
3. Do not modify or delete the L02 OIDC application.

## Conclusion

L03 successfully demonstrated SAML federation and application assignment in Microsoft Entra ID. Microsoft Entra ID authenticated the assigned user and issued a SAML response accepted by the Toolkit. An unassigned user was blocked with `AADSTS50105`, proving that authentication and application authorization are separate controls.

## References

- [Configure Microsoft Entra SAML Toolkit for single sign-on](https://learn.microsoft.com/en-us/entra/identity/saas-apps/saml-toolkit-tutorial)
- [Enable SAML single sign-on for an enterprise application](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/add-application-portal-setup-sso)
- [Properties of an enterprise application](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/application-properties)
