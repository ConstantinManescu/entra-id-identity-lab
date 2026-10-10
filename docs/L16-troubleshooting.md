# L16 - Troubleshooting Identity Access

**Status:** COMPLETED (two controlled troubleshooting cases)

**Lab date:** 2026-10-10

**Application:** Microsoft Entra SAML Toolkit

**Policy:** CA-L16-Toolkit-Block-Andrei

## Objective

Diagnose and resolve two access failures using enterprise application assignments, Conditional Access configuration, and interactive sign-in logs. Compare affected users with working users and verify recovery after each correction.

## Environment and scope

- Test users: Ana Maria, Alex, Andrei, and Claudiu Auditor.
- Microsoft Entra ID P2 licences were reported active for the four test users.
- The existing L03 SAML Toolkit application was reused.
- Initially, only Ana Maria was assigned to the application.
- Application assignment was required.
- Temporary test-user assignments and a dedicated Conditional Access policy were used.
- L12 access reviews were outside the scope of these controlled tests.

## Evidence timeline

The portal displays UTC timestamps, indicated by the trailing Z. On this date, Europe/Bucharest was UTC+03:00. These are sign-in event times, not screenshot capture times or configuration-change times.

| Event | UTC timestamp | Bucharest time | Result | Evidence |
| --- | --- | --- | --- | --- |
| Ana baseline sign-in | 2026-10-10T12:59:28Z | 2026-10-10 15:59:28 | Success | Visible in screenshots 02 and 03 |
| Alex without assignment | 2026-10-10T13:02:06Z | 2026-10-10 16:02:06 | Failure: 50105 | Screenshot 02 |
| Alex after assignment | 2026-10-10T13:08:04Z | 2026-10-10 16:08:04 | Success | Screenshot 03 event list |
| Alex additional successful sign-in | 2026-10-10T13:08:43Z | 2026-10-10 16:08:43 | Success | Screenshot 03 event list |
| Andrei during block test | 2026-10-10T14:13:55Z | 2026-10-10 17:13:55 | Failure: 53003 | Screenshot 05 |
| Claudiu comparison sign-in | 2026-10-10T14:15:16Z | 2026-10-10 17:15:16 | Success | Screenshot 06 |
| Andrei after policy was disabled | 2026-10-10T15:28:47Z | 2026-10-10 18:28:47 | Success | Screenshot 07 |

Screenshots 01 and 04 do not display an event timestamp. Exact assignment and policy-change times are not established by the supplied screenshots.

## Case 1 - Missing application assignment

### Initial state and failure

The application's Users and groups page showed Ana Maria as the only assigned user. Alex attempted to sign in and received error 50105 at 13:02:06 UTC.

The failure reason stated that the application required assigned access and that the requesting user had neither a qualifying group assignment nor a direct assignment.

### Diagnosis and correction

The failure was an application-assignment problem. A P2 licence and the ability to authenticate did not grant application access.

Alex was assigned to the enterprise application while the assignment requirement was retained. Sign-in was tested again.

### Validation

The event list shows successful Alex sign-ins at 13:08:04 UTC and 13:08:43 UTC. Ana's successful baseline event at 12:59:28 UTC provides a working comparison.

Screenshot 03 is captured on the Authentication details tab. Its detail row shows an authentication step at 13:08:02 UTC, while the event list separately shows the subsequent successful sign-ins. The authentication-step timestamp is not used as the overall successful sign-in timestamp.

**Outcome:** The assignment-related failure was resolved, and Entra recorded successful sign-ins after the correction.

## Case 2 - Conditional Access block

### Configuration and failure

Andrei and Claudiu were assigned to the application for the controlled test.

The dedicated policy CA-L16-Toolkit-Block-Andrei was configured with:
- Andrei as the only included user.
- One target resource, configured for the SAML Toolkit application.
- Block access as the grant control.
- No configured network condition, additional conditions, or session controls.
- Policy state On.

Screenshot 04 shows Andrei-only inclusion, one resource included, Block access, and On. It does not display the resource's name or the identities of excluded users.

Andrei's sign-in failed at 14:13:55 UTC with error 53003. The failure reason explicitly states that Conditional Access blocked access and prevented token issuance.

### Comparison and correction

Claudiu signed in successfully at 14:15:16 UTC while the controlled block test was in progress.

The lab policy was then disabled and Andrei's sign-in was tested again.

### Validation and evidence limits

Andrei's sign-in succeeded at 15:28:47 UTC after the policy was disabled.

The combination of the policy configuration, Andrei's Conditional Access failure, Claudiu's successful comparison, and Andrei's recovery supports the controlled test outcome.

Screenshot 05 shows Basic info rather than the event's Conditional Access tab. It proves a Conditional Access block but does not independently show the responsible policy's per-event result. Screenshot 06 proves Claudiu's successful sign-in but does not display the policy's Not applied result.

**Outcome:** The controlled Conditional Access failure was followed by a successful recovery test.

## Authentication observations

Claudiu's and Andrei's successful event details state that the MFA requirement was satisfied by a claim in the token. This does not establish that a new MFA challenge occurred during those particular attempts.

An Interrupted event can appear before a successful sign-in. Its status and authentication steps must be interpreted separately from the final successful event.

## Cleanup

The intended restored state is:
- CA-L16-Toolkit-Block-Andrei is Off.
- Only Ana Maria retains the original application assignment.
- Temporary assignments for Alex, Andrei, and Claudiu are removed.
- The SAML configuration remains unchanged.

No separate L16 cleanup screenshot was retained. Screenshot 07 verifies Andrei's recovery but does not independently prove the final saved policy state. The subsequent L17 baseline screenshot and L17 post-cleanup assignment screenshot corroborate that the application returned to Ana Maria's original direct assignment. Final saved state of the retained L16 policy was not independently recorded in this evidence set.

## L12 investigation context

Separately, two L12 access reviews remained in Applying. Earlier investigation included inspecting review state through Microsoft Graph, manually removing group members, and deleting one reviewed group. Directory changes were reflected in audit logs, but the review state remained unresolved.

A service-side issue is suspected; Microsoft's internal root cause was not confirmed. No Microsoft support case was opened. Those earlier changes cannot explain why the original stall began. L12 was left untouched during these L16 tests, and this report does not claim the access-review issue was fixed.

## Evidence

- [Initial application assignments](../screenshots/L16/01-app-assignments-alex-missing-redacted.png)
- [Alex assignment failure](../screenshots/L16/02-alex-assignment-failure-log-redacted.png)
- [Alex successful sign-ins after assignment](../screenshots/L16/03-alex-sign-in-success-after-assignment-redacted.png)
- [Enabled Andrei block policy](../screenshots/L16/04-ca-policy-andrei-toolkit-block-enabled-redacted.png)
- [Andrei Conditional Access failure](../screenshots/L16/05-andrei-ca-block-failure-log-redacted.png)
- [Claudiu successful comparison](../screenshots/L16/06-claudiu-control-sign-in-success-redacted.png)
- [Andrei recovery after policy was disabled](../screenshots/L16/07-andrei-sign-in-success-after-policy-disabled-redacted.png)

## Lessons learned

- Distinguish application assignment failures from Conditional Access blocks.
- Use the exact user, application, timestamp, error code, and failure reason to identify the relevant event.
- Change one access control at a time and compare affected and unaffected users.
- Verify recovery using new sign-in events.
- Separate observed outcomes from inferred causes and unsupported claims.
- Preserve timestamps and useful error details while redacting personal identifiers.

## References

- [Troubleshoot AADSTS50105](https://learn.microsoft.com/en-us/troubleshoot/entra/entra-id/app-integration/error-code-AADSTS50105-user-not-assigned-role)
- [Troubleshoot Conditional Access](https://learn.microsoft.com/en-us/entra/identity/conditional-access/troubleshoot-conditional-access)
