# L12 — Access Review

**Status:** BLOCKED — lab attempt closed with an unresolved application limitation

**Lab dates:** 8–11 October 2026

**Final assessment:** Review configuration and reviewer decisions were demonstrated. Review-driven membership removal and the non-response fallback outcome were not validated because result application remained in `Applying`.

## Objective

Review continued membership of an assigned security group, distinguish reviewer decisions from enforcement, and manually apply results to retain approved access and remove denied access.

## Environment and scope

- Microsoft Entra ID P2 licenses were assigned to the four test users and administrative users, as confirmed during the lab.
- The administrator configured and managed the review.
- Claudiu Auditor performed the review through My Access.
- The original target was a cloud-managed Security group with Assigned membership.
- Ana Maria, Alex and Andrei were direct members.
- Claudiu was the reviewer rather than a member of the target group.
- Administrative and emergency accounts were outside the reviewed membership.
- The group had no application or role assignments; the exercise tested group membership rather than effective application access.
- No Azure compute or storage resources were created for this lab.

## Original review configuration

| Setting | Value |
|---|---|
| Group | `grp-l12-access-review-pilot` |
| Review | `L12-Pilot-Group-Access-Review` |
| Scope | Everyone in the selected group |
| Reviewer | Claudiu Auditor |
| Review stages | Single stage |
| Frequency | One time |
| Auto-apply results | Disabled |
| If reviewers do not respond | No change |
| Denied guest action shown in the creation summary | Remove membership |
| Scheduled end | 9 October 2026 at 15:31:54 Europe/Bucharest |

The displayed guest action did not configure a 30-day block-and-delete process. Its appearance in the summary does not establish that the test users were guests.

## Procedure and observed results

1. Created the pilot group with Ana Maria, Alex and Andrei as direct members.
2. Created the one-time review with manual result application.
3. Signed in to My Access as Claudiu.
4. Approved Ana Maria and denied Alex, with business justifications.
5. Left Andrei unanswered to exercise the configured No change fallback.
6. Stopped the review before its scheduled end.
7. Verified that all three users remained members before application.
8. Requested manual application of the completed review.
9. Observed that the review entered Applying without reaching Result applied.

| User | Reviewer decision | Intended membership outcome | Validated outcome |
|---|---|---|---|
| Ana Maria | Approve | Retain membership | Decision recorded; application not validated |
| Alex | Deny | Remove membership | Decision recorded; Alex remained before manual troubleshooting removal |
| Andrei | Not reviewed | Retain membership through No change | Unanswered item recorded; fallback application not validated |

Ana Maria's justification was “Continued project participation requires membership.”

Alex's justification was “Project assignment completed; membership is no longer required.”

## Investigation and second attempt

The original review remained Applying for more than 24 hours and beyond its scheduled end. At closure on 11 October, the user reported that application was still pending across the three calendar dates of the investigation; this is not a measured claim of 72 elapsed hours.

Checks performed during the investigation included:

- Confirming the target group was cloud-managed, assigned and directly populated.
- Inspecting audit logs: Claudiu's Deny decision was recorded successfully.
- Exporting review results: all three entries showed Not applied and empty Applied Date fields at that checkpoint.
- Reading the original instance and decisions through Microsoft Graph using delegated `AccessReview.Read.All`.
- Confirming the API also reported Applying, so the symptom was not limited to the portal display.
- Observing an empty instance `errors` array.
- Observing Alex's `decision: Deny`, `applyResult: New` and `appliedDateTime: null`.

An empty error array did not establish successful processing or identify the cause.

A fresh review, `L12-Project-Access-Certification`, was created against `grp-l12-project-access`. It also reached Applying and remained there. The retained final screenshot shows both reviews in that state. It does not independently show the second review's individual decisions.

No completed natural-expiry comparison was supplied for this report. The investigation therefore did not prove that early stopping or an unanswered item caused the problem.

Detailed troubleshooting belongs in L16; this report records the L12 outcome.

## Manual cleanup and final state

During troubleshooting, the administrator manually removed all members from the original pilot group. The user confirmed that audit logs reflected those removals.

The administrator then deleted `grp-l12-access-review-pilot`. The user confirmed a corresponding group-deletion audit event. The original review nevertheless remained Applying.

These manual changes were cleanup and troubleshooting actions. They were not performed by successful access review result application.

The final retained screenshot still lists both review records as Applying, including the original resource name. A resource name remaining visible in the review list is not proof that the deleted group still exists.

At closure:

- The original group had been manually emptied and deleted.
- The original review remained unresolved.
- The fresh review also remained Applying.
- Deletion of the fresh group was not confirmed.
- No review-driven membership removal was demonstrated.
- No user-account deletion was reported.
- The root cause was not confirmed. A suspected service-processing defect remains a hypothesis rather than an established diagnosis.

The lab attempt is closed and documented as BLOCKED. It is not marked as a successful end-to-end application test.

## Evidence

The retained screenshots are stored under `screenshots/L12/`.

| Screenshot | What it demonstrates |
|---|---|
| [01-pilot-group-members-before-redacted.png](../screenshots/L12/01-pilot-group-members-before-redacted.png) | Initial three direct members |
| [02-review-configuration-redacted.png](../screenshots/L12/02-review-configuration-redacted.png) | Review name, scope, one-time schedule, manual application and No change |
| [03-claudiu-review-decisions-redacted.png](../screenshots/L12/03-claudiu-review-decisions-redacted.png) | Claudiu's approval of Ana Maria, denial of Alex and unanswered Andrei |
| [04-members-unchanged-before-apply-redacted.png](../screenshots/L12/04-members-unchanged-before-apply-redacted.png) | Three members still present at the pre-application checkpoint |
| [05-Access-reviews-stuck-in-applying.png](../screenshots/L12/05-Access-reviews-stuck-in-applying.png) | Both original and fresh reviews in Applying |

Screenshots 01–04 evidence the original run. Screenshot 05 additionally documents the fresh attempt. The Graph results and cleanup observations above were recorded during the investigation; they are not independently evidenced by this five-image set.

Raw CSV exports and Graph responses containing identifiers or user principal names are excluded from the public evidence set.

## Lessons learned

- A reviewer decision and successful result application are separate events.
- Actual group membership must be checked alongside review status.
- A successful Deny decision audit event does not prove removal.
- Portal, CSV, Graph and audit evidence can be correlated without establishing a root cause.
- Manual cleanup must be distinguished from review-driven enforcement.
- An unresolved outcome can be documented accurately without claiming completion or a confirmed platform bug.

## References

- [Create an access review](https://learn.microsoft.com/en-us/entra/id-governance/create-access-review)
- [Complete and apply an access review](https://learn.microsoft.com/en-us/entra/id-governance/complete-access-review)
- [Microsoft Graph access review decision properties](https://learn.microsoft.com/en-us/graph/api/resources/accessreviewinstancedecisionitem?view=graph-rest-1.0)
- [Microsoft Graph applyDecisions](https://learn.microsoft.com/en-us/graph/api/accessreviewinstance-applydecisions?view=graph-rest-1.0)
