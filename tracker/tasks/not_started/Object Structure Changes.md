# Title: Additional Fields
- Category: **Object Structure**
- Status: * **Not started** *

## Comments
- **PERSON**
 - Sex
  - **Gender** (nullable field) with the following choices:
    - M
    - F
    - NGS
    - blank
 - **Body Weight/Mass (start)** (nullable field) (in Kg - not Newtons)
   - datatype: float
 - **Height** (in m)
   - datatype: float
 - Auto Calculate
   - **AutoBMI** from Weight & Height = (Weight (kg)/Height (m))/Height (m)
   - Calorific intake
   - ideal Weight
   - other things??
- **TRAINING_PLAN**
 - **Objectives** (from an enumerated list):
   - Gain Muscle
   - Lose Weight
   - General Fitness
   - Toning
   - other things??
- **PROGRESS**
    - **Body Weight/Mass** (nullable field) (in Kg)
    - **AutoBMI**

## Ideas
 - Body weight tracking over time (based on PLAN type/objectives)
 - Selection of PLAN objective auto-selects the right exercises - based on user data
