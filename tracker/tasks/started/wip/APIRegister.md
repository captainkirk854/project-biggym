# Title: Register API Stored Procedures
- Category: **Framework Stored Procedures and Functions**
- Status: * **In progress** *

## Comments
- These stored procedures are designed to make it easier to create or update from a single call.
- Their behaviour is determined by the ObjectId argument
 - when NULL - **create**
 - when NOT NULL and a valid Id number for the object of interest - **update**

## List of Stored Procedures
- *spRegisterExercise*
- *spRegisterPerson*
- *spRegisterProfile*
- *spRegisterProgressEntry*
- *spRegisterTrainingPlan*
- *spRegisterTrainingPlanDefinition*
