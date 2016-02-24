# Title: Additional Fields
- Category: **Object Structure**
- Status: * **Not started** *

## Comments
- **PERSON**
 - **Gender** (nullable field) with the following choices:
   - M
   - F
   - NGS
   - blank
 - **Height** (in m)
   - datatype: float
- **TRAINING_PLAN**
 - **Objectives** (from an enumerated list):
   - Gain Muscle
   - Lose Weight
   - General Fitness
   - Toning
   - other things??
- **PROGRESS**
    - **Session Comments** (nullable field)
    - **Body Weight/Mass** (nullable field) (in Kg)

## Ideas
 - Body weight tracking over time (based on PLAN type/objectives)
 - Selection of PLAN objective auto-selects the right exercises - based on user data

 - **Auto calculate (from PROGRESS)**
  - BMI
    - from Weight & Height = (Weight (kg)/Height (m))/Height (m)
  - Calorific intake
  - ideal Weight
  - other things??
