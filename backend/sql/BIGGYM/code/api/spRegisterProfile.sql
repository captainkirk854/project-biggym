/*
Name       : spRegisterProfile
Object Type: STORED PROCEDURE
Dependency : 
            TABLE:
                - PROFILE
                - PERSON
            
            STORED PROCEDURE :
                - spDebugLogger 
                - spErrorHandler
                - spCreatePerson
                - spGetIdForProfile
*/

use BIGGYM;

drop procedure if exists spRegisterProfile;
delimiter $$
create procedure spRegisterProfile(in vNew_ProfileName varchar(32),
                                   in vFirstName varchar(32),
                                   in vLastName varchar(32),
                                   in vBirthDate date,      
                                  out ObjectId mediumint unsigned,
                                  out ReturnCode int,
                                  out ErrorCode int,
                                  out ErrorState int,
                                  out ErrorMsg varchar(512))
begin

    -- Declare ..
    declare ObjectName varchar(128) default 'PROFILE';
    declare SprocName varchar(128) default 'spRegisterProfile';
    declare vPersonId mediumint unsigned default NULL;
    
    declare SignificantFields varchar(256) default concat('NAME = <', vNew_ProfileName, '>');
    declare ReferenceObjects varchar(256) default concat(' PERSONid(', 'FIRST_NAME = <', vFirstName, '> ', 'LAST_NAME = <', vLastName, '> ', 'BIRTH_DATE = <', vBirthDate, '>)' );
    declare SprocComment varchar(512) default concat('insert into object field list [', SignificantFields, '] ', 'using reference(s) [', ReferenceObjects, ']');
    
    declare tStatus varchar(64) default '-';
    
    -- -------------------------------------------------------------------------
    -- Error Handling -- 
    -- -------------------------------------------------------------------------
    declare EXIT handler for SQLEXCEPTION
        begin
           set SprocComment = concat('SEVERITY 1 EXCEPTION: ', SprocComment);
          call spErrorHandler (ReturnCode, ErrorCode, ErrorState, ErrorMsg);
          call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);
        end;

    -- Variable Initialisation ..
    set ReturnCode = 0;
    set ErrorCode = 0;
    set ErrorState = 0;
    set ErrorMsg = '-';
    -- -------------------------------------------------------------------------
    -- Error Handling --
    -- -------------------------------------------------------------------------
    
    -- Clean character input ..
    set vNew_ProfileName = strcln(vNew_ProfileName);

    -- Check for valid input ..
    if(length(vNew_ProfileName) != 0) then

        -- Attempt pre-emptive person creation ..
        call spCreatePerson (vFirstName, 
                             vLastName, 
                             vBirthDate, 
                             vPersonId, 
                             ReturnCode, 
                             ErrorCode,
                             ErrorState,
                             ErrorMsg);
       
        -- Attempt Profile registration ..
        if (vPersonId is NOT NULL) then
            call spGetIdForProfile (vNew_ProfileName, vPersonId, ObjectId, ReturnCode);
            if (ObjectId is NULL) then
                insert into 
                        PROFILE
                        (
                         NAME,
                         PERSONid
                        )
                        values
                        (
                         vNew_ProfileName,
                         vPersonId
                        );
                set tStatus = 'SUCCESS';
                call spGetIdForProfile (vNew_ProfileName, vPersonId, ObjectId, ReturnCode);
            else
                set tStatus = 'FIELD VALUE(S) ALREADY PRESENT';
            end if;
        else
            set tStatus = 'CANNOT FIND REFERENCE OBJECT(S)';
        end if;
    else
        set tStatus = 'ONLY ILLEGAL CHARACTERS IN ONE OR MORE FIELD VALUE(S)';
        set ReturnCode = -1;
    end if;
 
    -- Log ..
    set SprocComment = concat(SprocComment, ': OBJECT ID ', ifNull(ObjectId, 'NULL'));
    set SprocComment = concat(SprocComment, ':  ', tStatus);
    call spDebugLogger (database(), ObjectName, SprocName, SprocComment, ReturnCode, ErrorCode, ErrorState, ErrorMsg);   

end$$
delimiter ;


/*
Sample Usage:

call spRegisterProfile ('Faceman', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
call spRegisterProfile ('StarBuck', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
call spRegisterProfile ('Starbuck', 'Dirk', 'Benedict', '1945-03-01', @id, @returnCode, @errorCode, @stateCode, @errorMsg);
select @id, @returnCode, @errorCode, @stateCode, @errorMsg;
select * from PROFILE order by DATE_REGISTERED asc;
*/
