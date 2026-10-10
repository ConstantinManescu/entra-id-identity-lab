# L08 — Conditional Access Conditions and Sessions

**Status:** COMPLETED

**Completed:** 2026-10-03

**Phase:** trial_week_2

**Priority:** core

## Objective

Validate how Conditional Access conditions determine policy scope and how session controls affect authentication reuse. Test a one-hour sign-in frequency and browser session persistence separately, using pilot and control accounts without creating Azure resources.

## Environment and scope

- Microsoft Entra ID tenant with four test users: Ana Maria, Claudiu Auditor, Alex and Andrei.
- All four test users had Microsoft Entra ID P2 licenses for this lab.
- Windows browser access to Azure Portal.
- Separate normal browser profiles for simultaneous Ana and Alex sessions.
- An administrative session used to configure policies and inspect sign-in logs.
- Existing baseline policy: `CA-Baseline-Require-MFA`.
- Pilot users for the two L08 policies: Ana Maria and Claudiu Auditor, selected directly.
- Control users outside the L08 policies: Alex and Andrei.
- Administrative and emergency accounts remained outside the pilot scope.
- Policy configuration showed specific included users and specific excluded users; the evidence does not expose the individual exclusion list.

Alex was the principal control user for the recorded live tests. The evidence does not claim equivalent timed testing for all four accounts.

## Concepts validated

| Component | Purpose in this lab |
| --- | --- |
| User assignment | Apply L08 controls to Ana and Claudiu while leaving Alex and Andrei outside the pilot |
| Device platform condition | Match Windows browser access for the sign-in-frequency policy |
| Client apps condition | Match Browser access rather than mobile/desktop or legacy clients |
| Grant controls | Preserve the existing baseline MFA requirement |
| Sign-in frequency | Require periodic fresh authentication after one hour when authentication is evaluated |
| Persistent browser session | Compare Always persistent with Never persistent |
| What If | Simulate matching and nonmatching conditions |
| Sign-in logs | Confirm policy application for actual sign-ins |

The two L08 policies used Session controls without adding another Grant requirement. The baseline MFA policy remained enabled. All resources was the target scope; this did not grant Azure resource permissions or create subscriptions.

## Policy 1 — Windows browser sign-in frequency

The final saved policy name shown in the live sign-in logs was:

`CA-L08-Windows-Browser-SIF-1H`

Earlier configuration and What If captures show capitalization variants of the same lab policy name.

| Setting | Configuration |
| --- | --- |
| Included users | Ana Maria and Claudiu Auditor |
| User assignment | Direct selection of pilot users; specific exclusions configured |
| Target resources | All resources |
| Network | Not configured |
| Device platforms | Windows |
| Client apps | Browser only |
| Risk conditions and device filters | Not configured |
| Grant | No additional grant controls |
| Session — Sign-in frequency | Periodic reauthentication, 1 hour |
| Session — Persistent browser session | Not configured |
| Deployment | Report-only, then On for live testing, then Off for cleanup |

The configuration screenshots show one included device platform but do not display its value. Windows was the intended platform used in the test configuration. The What If screenshots capture results rather than the complete simulation inputs.

### Conditions validation

The following What If scenarios were run:

| Scenario | Observed result for the L08 SIF policy |
| --- | --- |
| Ana — Windows — Browser | Listed among policies that apply, in Report-only state |
| Alex — Windows — Browser | Absent from the policies-that-apply list; baseline MFA remained applicable |
| Ana — Android — Browser | Absent from the policies-that-apply list; the baseline MFA policy remained applicable |

The Android scenario was a simulation, not an actual Android sign-in. The saved negative screenshots show the applying-policy list; they do not display the nonapplying-policy reason or all supplied inputs.

Report-only was used before enforcement. Report-only sign-in-log screenshots were not required for the retained evidence set. Report-only evaluation was not treated as proof of enforced session behavior.

### Live timed test

1. Enabled the SIF policy while retaining the baseline MFA policy.
2. Established separate authenticated sessions for Ana and Alex in normal browser profiles.
3. Confirmed that the SIF policy applied to Ana and did not apply to Alex.
4. Kept Ana's session intact during the interval rather than signing out to manufacture a new authentication prompt.
5. Observed a fresh authentication challenge after more than one hour.
6. Reviewed the subsequent Ana sign-in and its Conditional Access results.

| Event | Local time shown in the original SIF screenshots |
| --- | --- |
| Ana initial sign-in | 2026-10-03 16:06:33 |
| Alex control sign-in selected in screenshot 07 | 2026-10-03 16:07:11 |
| Ana subsequent sign-in | 2026-10-03 17:13:10 |
| Interval between Ana's two sign-ins | 1 hour 6 minutes 37 seconds |

At the initial Ana sign-in, `CA-Baseline-Require-MFA` and the L08 SIF policy showed **Success**. Alex's recorded control event showed baseline MFA **Success** and L08 **Not Applied**.

A Windows Security passkey sign-in dialog was observed during the timed test. The retained evidence set below focuses on the initial and subsequent sign-in logs; it does not establish which authentication method was ultimately completed. The subsequent sign-in showed the baseline MFA policy and L08 SIF policy **Success**.

The observed challenge and the two event timestamps support the timed reauthentication result. A Conditional Access Success result alone does not prove why a prompt occurred. The captured evidence does not include Authentication Details identifying the completed method.

### SIF result

- Ana was subject to the one-hour session control.
- Alex's recorded sign-in was outside the L08 scope while still protected by baseline MFA.
- Ana's subsequent sign-in occurred 66 minutes 37 seconds after the initial event, following an observed authentication challenge.
- No claim is made that sign-in frequency causes an exact browser logout at minute 60. Enforcement depends on subsequent authentication evaluation and application activity.

The SIF policy was disabled before the persistence test to separate the two controls.

## Policy 2 — Browser persistence

Policy name:

`CA-L08-Browser-Persistence`

| Setting | Configuration |
| --- | --- |
| Included users | Ana Maria and Claudiu Auditor |
| User assignment | Direct pilot selection; specific exclusions configured |
| Target resources | All resources |
| Network | Not configured |
| Device platforms | Not configured |
| Client apps | Browser only |
| Other conditions | Not configured |
| Grant | No additional grant controls |
| Sign-in frequency | Not configured |
| Persistent browser session | Always persistent for the initial comparison; then Never persistent |
| Deployment | Report-only before enforcement; On during the live comparison; Off for cleanup |

All resources was used because the persistence control governs the shared Entra browser authentication session. The baseline MFA requirement remained in place.

### Initial comparison

Configured Always persistent for the baseline, then changed the policy to Never persistent and saved it in the On state. The saved-policy screenshot confirms the final Never persistent setting and the enabled policy state.

### Troubleshooting observation

After changing to Never persistent, Ana initially returned to Azure Portal without an authentication prompt after browser windows were closed. Sign-in logs still showed the persistence policy **Success**.

This was not treated as proof that the policy had failed or that the browser session had ended. Closing profile windows does not, by itself, establish that the entire browser has exited. Background execution, session restoration, application state and device single sign-on can affect the result.

### Controlled retest

The comparison was repeated with a fresh session under Never persistent and a complete browser exit. The retest kept the SIF policy disabled and retained baseline MFA. Browser closure, rather than signing out between the two measured accesses, was the action being tested.

After the browser was closed and reopened, Ana was required to authenticate again. Two corresponding interactive Azure Portal sign-in events were captured:

| Event | UTC timestamp in the persistence screenshots | Europe/Bucharest equivalent |
| --- | --- | --- |
| Initial session | 2026-10-03 17:23:07 UTC | 2026-10-03 20:23:07 |
| Sign-in after browser closure/reopening | 2026-10-03 17:24:53 UTC | 2026-10-03 20:24:53 |
| Interval | 1 minute 46 seconds | 1 minute 46 seconds |

The persistence screenshots use UTC; the earlier SIF screenshots use local display time. These time formats were not mixed when calculating intervals.

Both captured persistence events showed:

- `CA-Baseline-Require-MFA`: **Success**.
- `CA-L08-Browser-Persistence`: **Success**.
- Session control: `PersistentBrowserSessionMode`.
- `CA-L08-Windows-Browser-SIF-1H`: **Disabled**.
- `CA-L07-Controlled-Block-Pilot`: **Disabled** during these events.

### Persistence result and limits

The observed reauthentication after the complete browser exit, together with the fresh events and applied persistence control, supports the Never persistent result.

The comparison established that a complete browser exit was required for this test environment. It did not establish the exact internal cause of the earlier silent reopening. No claim is made that a specific background process, cookie or Primary Refresh Token was conclusively identified.

The retained screenshots show policy results and timestamps, not a separate screenshot of the persistence authentication challenge or its completed authentication method.

## Screenshot evidence

Evidence directory: `screenshots/L08/`.

The retained evidence is listed below.

| Filename | Evidence |
| --- | --- |
| `01-sif-policy-assignments-redacted.png` | Pilot inclusion, All resources and initial Report-only state |
| `02-sif-policy-conditions-and-session-redacted.png` | Browser-only condition, one included platform and one-hour session setting |
| `03-alex-what-if-windows-platform-browser-not-applied-redacted.png` | Applying-policy list for the Alex simulation |
| `04-ana-what-if-windows-platform-browser-applied-redacted.png` | L08 policy listed as applicable in the Ana simulation |
| `05-ana-what-if-android-platform-browser-not-applied-redacted.png` | Applying-policy list for the Android simulation |
| `06-ana-sif-initial-login-policy-on-result-redacted.png` | Initial Ana event with SIF and baseline MFA Success |
| `07-alex-sif-initial-login-policy-on-result-redacted.png` | Alex control event with L08 Not Applied and baseline MFA Success |
| `08-ana-sif-reauthentication-required-redacted.png` | Windows Security passkey authentication challenge during the timed SIF test; QR code removed |
| `09-ana-sif-reauthentication-rquiered-login-policy-on-result-redacted.png` | Subsequent Ana sign-in with enforced SIF Success |
| `10-browser-persistent-session-policy-conditions-and-session-redacted.png` | Initial persistence-policy configuration with Always persistent |
| `11-browser-never-persistent-policy-redacted.png` | Existing policy with Never persistent and On state |
| `12-ana-never-persistence-enforced-policy-result-redacted.png` | Initial persistence-test event and applied controls |
| `13-ana-never-persistence-reauthentication-enforced-policy-result-redacted.png` | Event after browser closure/reopening and applied controls |

A separate cleanup screenshot was not retained.

The retained evidence preserves timestamps, policy names, session controls and results. Authentication secrets and personal identifiers are excluded from the public evidence.

## Cleanup and final-state verification

The intended cleanup state was:

- `CA-L08-Windows-Browser-SIF-1H`: **Off**.
- `CA-L08-Browser-Persistence`: **Off**.
- `CA-Baseline-Require-MFA`: **On**.
- Any earlier lab policy temporarily changed is restored to its recorded pre-lab state. L07 should not be reenabled merely because it was disabled during this lab.
- Any Remember MFA setting temporarily changed is restored after the SIF policy is Off.
- Test profiles are signed out.

The intended final state retains the two L08 policies as Off. The retained screenshots do not independently confirm the final saved state; that verification was not recorded in this archive. No Azure resources were created for this lab, and the test-user licenses and MFA registrations are retained for subsequent identity labs.

## Lessons learned

1. Conditions select the circumstances under which a policy applies; session controls determine authentication-session behavior.
2. Existing MFA protection remains applicable even when the L08 policy does not match a control user.
3. What If is simulation evidence and must not be described as an actual sign-in from another platform.
4. Separate browser profiles permit simultaneous pilot/control sessions without repeated sign-outs or sequential hour-long tests.
5. Sign-in frequency is an authentication freshness requirement, not an exact page logout timer.
6. Policy Success confirms application, not the reason for every observed authentication interaction.
7. Persistence tests require a genuine browser-session boundary. Closing a profile window can be insufficient.
8. A valid comparison preserves session data between the measured close/reopen actions; clearing cookies at that point would confound the test.
9. Event timestamps and browser observations must be correlated, with UTC and local times handled consistently.

## Microsoft documentation

- [Conditional Access policies and evaluation](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-policies)
- [Conditional Access conditions](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-conditional-access-conditions)
- [Authentication session lifetime concepts](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-session-lifetime)
- [Configure authentication session management](https://learn.microsoft.com/en-us/entra/identity/conditional-access/howto-conditional-access-session-lifetime)
- [Conditional Access What If](https://learn.microsoft.com/en-us/entra/identity/conditional-access/what-if-tool)
- [Sign-in log activity details](https://learn.microsoft.com/en-us/entra/identity/monitoring-health/concept-sign-in-log-activity-details)
- [Browser background execution and session cookies in Microsoft Edge](https://learn.microsoft.com/en-us/deployedge/microsoft-edge-policies/BackgroundModeEnabled)
