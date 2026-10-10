# L05 — Dynamic User Group Membership
Status: COMPLETED
Execution date: 2026-10-02
Phase: trial_week_1
Group: grp-entra-l05-dynamic-users
Evidence: ../screenshots/L05/

## Objective

Create a Microsoft Entra ID security group whose membership is maintained from user attributes. Validate both matching and nonmatching users, demonstrate removal and re-entry after a Department change, demonstrate admission and removal after a Job title change, and verify an empty group after rollback.

## Environment and scope

The lab used the Microsoft Entra admin center, Microsoft 365 license information, and four directory users: Ana Maria, Claudiu Auditor, Andrei, and Alex.
The license screenshot shows Microsoft Entra ID P2 assigned to each of these four users. It does not show the subscription expiration or renewal terms, so no trial duration is claimed here.
Alex was the fourth user actually used in the exercise. Several screenshot filenames still contain the earlier label “test”; the visible user in those screenshots is Alex. The evidence filenames are preserved as captured.
The exercise concerned membership automation. Application access, Conditional Access enforcement, license inheritance, and administrator-role assignment were outside the tested scope.

## Group configuration


| Setting | Captured value |
| --- | --- |
| Group type | Security |
| Display name | grp-entra-l05-dynamic-users |
| Description | L05 dynamic membership lab using Department and Job title attributes. |
| Membership type | Dynamic User |
| Microsoft Entra roles can be assigned to the group | No |
| Owners in the captured creation form | No owners selected |



No later owner assignment is evidenced by this screenshot set.

## Membership rule

The portal-generated expression was:

```text
(user.department -eq "Entra-L05-Pilot") and (user.jobTitle -eq "L05-Eligible") and (user.accountEnabled -eq True) and (user.userType -eq "Member")
```

Every condition must match. A correct Department alone is insufficient when the Job title is different.

| Condition | Required value |
| --- | --- |
| Department | Entra-L05-Pilot |
| Job title | L05-Eligible |
| Account enabled | True |
| User type | Member |



The rule uses attribute equality and AND logic. It does not use the memberOf preview operator.

## Initial user attributes


| User | Department | Job title | Expected initial result |
| --- | --- | --- | --- |
| Ana Maria | Entra-L05-Pilot | L05-Eligible | Included |
| Claudiu Auditor | Entra-L05-Pilot | L05-Eligible | Included |
| Andrei | Entra-L05-Control | L05-Eligible | Excluded |
| Alex | Entra-L05-Pilot | L05-Control | Excluded |



The property screenshots record the input values. Rule validation records the evaluated result. Members screenshots record the actual group contents.

## Execution and results


### 1. Initial validation and population

The rule was validated against all four users. Ana Maria and Claudiu Auditor matched. Andrei and Alex did not match.
Andrei's verification details showed that Department failed, while Job title, accountEnabled, and userType passed. Alex's details showed that Job title failed, while Department, accountEnabled, and userType passed.
Actual initial membership contained Ana Maria and Claudiu Auditor, with two members and no entered search text.

### 2. Department change: Claudiu removal and re-entry

Claudiu Auditor's Department was changed from Entra-L05-Pilot to Entra-L05-Control while his Job title remained L05-Eligible.
The next captured member list contained only Ana Maria. Claudiu Auditor was absent.
After restoring Claudiu's Department to the pilot value in the lab sequence, the next captured member list contained Ana Maria and Claudiu Auditor again.
The screenshots demonstrate the intended removal and re-entry outcomes. They do not establish an exact processing interval.

### 3. Job title change: Alex admission and removal

Alex's Job title was changed from L05-Control to L05-Eligible while his Department remained Entra-L05-Pilot. The saved property screenshot records both eligible values.
The next captured member list contained Alex, Ana Maria, and Claudiu Auditor.
After returning Alex's Job title to the control value in the lab sequence, the next captured member list contained Ana Maria and Claudiu Auditor only.
Andrei remained absent from every captured member list.

### 4. Audit evidence

The audit screenshot shows an Add group event for grp-entra-l05-dynamic-users at 09:41:49 on 2026-10-02 in the portal's Local date display.
The Modified Properties view records:
- The group display name and description.
- GroupType containing DynamicMembership.
- SecurityEnabled set to true.
- MailEnabled set to false.
- The four-condition membership rule.
- MembershipRuleProcessingState set to On.
On means processing was enabled; it is not a captured Update complete status. The event result and initiator are not visible in the selected details tab.

### 5. Rollback verification

After the rollback phase, rule validation showed all four users as Not in group. The actual Members page showed zero group members and an empty search field.
The group and its rule remained available for inspection. These screenshots verify removal of lab eligibility and an empty final membership.
Exact restoration of the original Department and Job title values, and comparison of pre-existing group memberships against a private baseline, are not independently shown in this evidence set. They should not be inferred solely from an empty group.

## Test matrix


| Test | Observed result | Outcome |
| --- | --- | --- |
| Ana Maria meets the rule | Included in initial validation and membership | PASS |
| Claudiu Auditor meets the rule | Included in initial validation and membership | PASS |
| Andrei has the control Department | Excluded; Department failure shown in details | PASS |
| Alex has the control Job title | Excluded; Job title failure shown in details | PASS |
| Claudiu loses Department eligibility | Member count changes from two to one | PASS |
| Claudiu regains Department eligibility | Member count returns to two | PASS |
| Alex gains Job title eligibility | Member count changes from two to three | PASS |
| Alex loses Job title eligibility | Member count returns to two | PASS |
| Group creation is traceable | Add group event and configuration properties captured | PASS |
| Rollback removes lab eligibility | All four fail validation; actual membership is empty | PASS |



The observed membership sequence was: 2 → 1 → 2 → 3 → 2 → 0.

## Portal variation and evidence limits

The planned separate processing-status Overview screenshot was not captured because the expected status control was not available in the observed portal experience.
Actual Members screenshots were used to verify each resulting membership state. The creation audit also confirms that dynamic processing was enabled. A dedicated Update complete screenshot is therefore not referenced or claimed.
The accountEnabled and userType conditions were included in the rule, but no disabled-account or Guest-user negative scenario was performed in this evidence set. Administrative and emergency-account validation samples were not included in the captured results.

## Lessons learned

- Group membership can be maintained through controlled attribute changes instead of editing the member list.
- AND logic requires every condition to pass.
- Expression-level validation explains a failed match, while the Members page verifies the resulting membership.
- Department and Job title changes can affect access when a group is assigned to a resource; attribute write permissions therefore matter.
- Successful membership transitions should be recorded without claiming an exact service latency from screenshots lacking transition timestamps.
- Rollback needs both a failed-match check and an actual empty-member check.
- The final group is retained with zero members; retaining its rule makes the exercise easy to inspect.

## Evidence

The filenames below match the retained screenshots, including capitalization and the legacy test labels.

| File | Evidence |
| --- | --- |
| [01-license-state-redacted.png](../screenshots/L05/01-license-state-redacted.png) | Microsoft 365 Active users showing Microsoft Entra ID P2 assigned to the four lab users. |
| [02-ana-lab-attributes-redacted.png](../screenshots/L05/02-ana-lab-attributes-redacted.png) | Ana Maria: pilot Department and eligible Job title. |
| [03-claudiu-lab-attributes-redacted.png](../screenshots/L05/03-claudiu-lab-attributes-redacted.png) | Claudiu Auditor: pilot Department and eligible Job title. |
| [04-andrei-control-attributes-redacted.png](../screenshots/L05/04-andrei-control-attributes-redacted.png) | Andrei: control Department and eligible Job title. |
| [05-alex-control-attributes-redacted.png](../screenshots/L05/05-alex-control-attributes-redacted.png) | Alex: pilot Department and control Job title. |
| [06-new-dynamic-group-settings-redacted.png](../screenshots/L05/06-new-dynamic-group-settings-redacted.png) | Security group creation form with Dynamic User membership and role assignment disabled. |
| [07-dynamic-membership-rule-redacted.png](../screenshots/L05/07-dynamic-membership-rule-redacted.png) | Four equality conditions joined with AND. |
| [08-initial-rule-validation-redacted.png](../screenshots/L05/08-initial-rule-validation-redacted.png) | Ana Maria and Claudiu Auditor match; Andrei and Alex do not match. |
| [09-andrei-department-condition-failed-redacted.png](../screenshots/L05/09-andrei-department-condition-failed-redacted.png) | Andrei fails only the Department condition. |
| [10-Alex-job-title-condition-failed-redacted.png](../screenshots/L05/10-Alex-job-title-condition-failed-redacted.png) | Alex fails only the Job title condition. |
| [11-initial-dynamic-members-redacted.png](../screenshots/L05/11-initial-dynamic-members-redacted.png) | Actual initial membership: Ana Maria and Claudiu Auditor; two members. |
| [12-claudiu-department-changed-redacted.png](../screenshots/L05/12-claudiu-department-changed-redacted.png) | Claudiu Auditor moved to the control Department. |
| [13-claudiu-automatically-removed-redacted.png](../screenshots/L05/13-claudiu-automatically-removed-redacted.png) | Actual membership after Claudiu loses eligibility: Ana Maria; one member. |
| [14-claudiu-automatically-readded-redacted.png](../screenshots/L05/14-claudiu-automatically-readded-redacted.png) | Actual membership after Claudiu regains eligibility: Ana Maria and Claudiu Auditor; two members. |
| [15-test-job-title-changed-redacted.png](../screenshots/L05/15-test-job-title-changed-redacted.png) | Alex now has the eligible Job title; filename retains the earlier test label. |
| [16-test-automatically-added-redacted.png](../screenshots/L05/16-test-automatically-added-redacted.png) | Actual membership after Alex becomes eligible: Alex, Ana Maria and Claudiu Auditor; three members. |
| [17-test-automatically-removed-redacted.png](../screenshots/L05/17-test-automatically-removed-redacted.png) | Actual membership after Alex loses eligibility: Ana Maria and Claudiu Auditor; two members. |
| [18-group-creation-audit-event-redacted.png](../screenshots/L05/18-group-creation-audit-event-redacted.png) | Add group audit event and modified properties, including dynamic rule and processing state On. |
| [19-rollback-rule-validation-redacted.png](../screenshots/L05/19-rollback-rule-validation-redacted.png) | Final validation: all four users fail the retained rule. |
| [20-rollback-empty-membership-redacted.png](../screenshots/L05/20-rollback-empty-membership-redacted.png) | Final actual membership: zero members with an empty search field. |




## Microsoft documentation

- [Dynamic membership rules and supported attributes](https://learn.microsoft.com/en-us/entra/identity/users/groups-dynamic-membership)
- Create or update a dynamic membership group
- [Validate dynamic membership rules](https://learn.microsoft.com/en-us/entra/identity/users/groups-dynamic-rule-validation)
- Dynamic group processing
- Manage user profile properties

## Completion

The core L05 membership tests and final empty-group verification are complete. The report records the completed membership tests and the limits of the retained evidence.
