# Training Plan Definition

## Implementation Overview
### Back End

- **TRAINING_PLAN** (table):
- There is a thought that one person's training plan, if not marked as private, can be viewed by others and its definition cloned for their use
- Supporting stored procedures for creation, modification and deletion.
- Properties:
 - plan name
 - visibility toggle
 - link to user **PROFILE**


- **TRAINING_PLAN_DEFINITION** (table):
 - can consist of 0 to n exercises
 - this table contains the exercise definition with links to **EXERCISE** and **TRAINING_PLAN**
 - the day/order they should be performed in
 - Supporting stored procedures for creation, modification and deletion.
