
# Story 001
** Storage of: Pre-defined List of Body Parts and their Exercises **

##Implementation Overview
###Backend
- *EXERCISE* table: list of exercises and their associated bodypart - this list will be administrator moderated
                    and added to on request

# Story 002
** Storage of: Pertinent User Information **
- Forename
- Surname
- DOB
- Training Profile Name (multiple names are possible)

##Implementation Overview
###Backend

- *PERSON* table: 
    user personal details

- *PROFILE* table: 
    profile name and links to PERSON (1<-n)


# Story 003
** Storage of: Training Plan Definition (consists of 0 to n exercises arranged on a per-day basis)

##Implementation Overview
###Backend

- *TRAINING_PLAN* table: 
   plan name and visibility toggle 
   (idea that one person's training plan, if not private, can be viewed by others and its definition cloned for personal use)

- *TRAINING_PLAN_DEFINITION* table: 
   configurations of exercise (links to EXERCISE and PERSON) and the day/order they should 
   be performed in
