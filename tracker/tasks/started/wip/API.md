# Title: API Stored Procedures
- Category: **Framework Stored Procedures and Functions**
- Status: * **In progress** *

## Comments
- Base-level stored procedures are divided into restful/crud-like themes
  - create
  - delete
  - get
  - update

## List of Stored Procedures
- create
 - *spCreateExercise*
 - *spCreatePerson*
 - *spCreateProfile*
 - *spCreateProgressEntry*
 - *spCreateTrainingPlan*
 - *spCreateTrainingPlanDefinition*
- update
  - *spUpdateExercise*
  - *spUpdatePerson*
  - *spUpdateProfile*
  - *spUpdateProgressEntry*
  - *spUpdateTrainingPlan*
  - *spUpdateTrainingPlanDefinition*
- get
  - *spGetIdForExercise*
  - *spGetIdForPerson*
  - *spGetIdForProfile*
  - *spGetIdForProgressEntry*
  - *spGetIdForTrainingPlan*
  - *spGetIdForTrainingPlanDefinition*
- delete
  - need to decide whether data gets deleted or masked from views
  - delete has cascade option so that a delete from root object will auto-clean referential data
