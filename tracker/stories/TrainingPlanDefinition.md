**Storage of: Training Plan Definition (consists of 0 to n exercises arranged on a per-day basis)**

##Implementation Overview
###Backend

- *TRAINING_PLAN* table: 
   plan name and visibility toggle 
   (idea that one person's training plan, if not private, can be viewed by others and its definition cloned for personal use)

- *TRAINING_PLAN_DEFINITION* table: 
   configurations of exercise (links to EXERCISE and PERSON) and the day/order they should 
   be performed in
