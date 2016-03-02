use BIGGYM;

alter table PROFILE
add foreign key FK_PERSONID(PERSONid)
references PERSON(ID)
on delete cascade
on update cascade;

alter table TRAINING_PLAN
add foreign key FK_PROFILEID(PROFILEid)
references PROFILE(ID)
on delete cascade
on update cascade;

alter table TRAINING_PLAN_DEFINITION
add foreign key FK_PLANID(PLANid)
references TRAINING_PLAN(ID)
on delete cascade
on update cascade;

alter table TRAINING_PLAN_DEFINITION
add foreign key FK_EXERCISEID(exerciseId)
references EXERCISE(ID)
on delete cascade
on update cascade;

alter table PROGRESS
add foreign key FK_DEFINITIONID(DEFINITIONid)
references TRAINING_PLAN_DEFINITION(ID)
on delete cascade
on update cascade;
