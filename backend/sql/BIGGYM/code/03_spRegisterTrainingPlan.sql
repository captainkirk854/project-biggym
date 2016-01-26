/*
Name       : RegisterTrainingPlan
Object Type: STORED PROCEDURE
Dependency : TRAINING_PLAN(TABLE), spRegisterProfile (STORED PROCEDURE)
*/

use BIGGYM;

drop procedure if exists spRegisterTrainingPlan;
delimiter $$
create procedure spRegisterTrainingPlan(in vTrainingPlanName varchar(128),
                                        in vProfileName varchar(32),
                                        in vFirstName varchar(32),
                                        in vLastName varchar(32),
                                        in vBirthDate date,
                                       out ObjectId smallint,
                                       out ReturnCode int,
                                       out ErrorCode int,
                                       out ErrorMsg varchar(512))
begin

    declare vProfileId smallint default NULL;
    
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
     declare CONTINUE handler for SQLEXCEPTION
        begin
          call spErrorHandler (ReturnCode, ErrorCode, ErrorMsg);
        end;
 
    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Error Handling --
    -- -------------------------------------------------------------------------


    -- Attempt pre-emptive profile registration ..
    call spRegisterProfile (vProfileName, 
                            vFirstName, 
                            vLastName, 
                            vBirthDate, 
                            vProfileId, 
                            returnCode, 
                            errorCode, 
                            errorMsg);
    if(errorCode = 1062) then
        select concat(vProfileName, ' already registered to ', vFirstName, ' ', vLastName, ' born on: ', Birthdate, ' ProfileID: ', vProfileId);
    end if;
 
    -- Attempt TrainingPlan registration ..
    if (vProfileId is NOT NULL) then
        insert into 
                TRAINING_PLAN
                (
                 NAME,
                 PROFILEid
                )
                values
                (
                 vTrainingPlanName,
                 vProfileId
                )
            ;
    end if;
    
    -- Get ID ..
    set ObjectId = NULL;
 
    select 
        ID
    into
        ObjectId
    from 
        TRAINING_PLAN 
    where 
        NAME = vTrainingPlanName 
    and 
        PROFILEid = vProfileId
    limit 1
      ; 
      
    -- If ID found, reset ReturnCode to 0 ..
    if (ObjectId is NOT NULL and ReturnCode != 0) then
        set ReturnCode = 0;
    end if;   

end$$
delimiter ;


-- Sample Usage --
call spRegisterTrainingPlan ('Get Bigger Workout', 'Faceman', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;
call spRegisterTrainingPlan ('Get Bigger Workout', 'Mr.T', 'Lawrence', 'Tureaud', '1945-03-01', @id, @returnCode, @errorCode, @errorMsg);
select @id, @returnCode, @errorCode, @errorMsg;
select * from TRAINING_PLAN order by DATE_REGISTERED asc;
-- Sample Usage --
