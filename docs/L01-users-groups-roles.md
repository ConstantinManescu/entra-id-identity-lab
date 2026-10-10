# L01 — Users, Groups and Roles

## Objective

Create a Security group, add test users and test a direct Microsoft Entra role assignment.

## Group created

- Name: `grp-entra-lab-users`
- Type: Security
- Membership type: Assigned
- Members: 2 test users
- Role-assignable: not configured
- Role assigned to the group: no
- Group retained for future labs: yes

## Role tested

- Role: Directory Readers
- Assignment type: direct assignment to one test user
- Assignment through the group: no
- Role inheritance through the group: not tested
- Existing roles on the test user: retained because this is a training tenant

## Result

- Security group created: yes
- Assigned membership verified: yes
- Two test users added to the group: yes
- Directory Readers assigned directly to one test user: yes
- The second group member does not inherit the role: confirmed
- Existing roles modified: no
- Trials activated: no

## Conclusion

This lab demonstrated the difference between group membership and direct Microsoft Entra role assignment. Assigning a role directly to one user does not automatically grant the same role to the other members of the group.