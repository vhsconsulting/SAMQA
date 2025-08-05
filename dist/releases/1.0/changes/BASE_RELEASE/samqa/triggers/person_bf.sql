-- liquibase formatted sql
-- changeset SAMQA:1754374166079 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\person_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/person_bf.sql:null:b55922b4bbec0f17b5f232327d8e826bb2e11af1:create

create or replace editionable trigger samqa.person_bf before
    insert or update on samqa.person
    for each row
begin
  -- Carriage returns were being written in address which causes
  -- metavante to reject the files
    :new.address := replace(
        replace(:new.address,
                chr(10),
                ' '),
        chr(13),
        ' '
    );

    :new.division_code := upper(:new.division_code);
    :new.ssn := replace(
        replace(
            replace(:new.ssn,
                    chr(10),
                    ''),
            chr(13),
            ''
        ),
        ' '
    );

    if length(:new.zip) < 5 then
        :new.zip := lpad(:new.zip,
                         5,
                         '0');
    end if;

 -- Commented by Swamy on 18/02/2020 due to Mutating Trigger Production issue.
 -- The below code is moved to Apex Screen 2 (Personal Information) in the Process update_online_users
/*
IF :NEW.SSN <> :OLD.SSN THEN

   UPDATE online_users
   SET    tax_id = REPLACE(:NEW.SSN,'-')
   where  tax_id = REPLACE(:OLD.SSN,'-')
   and    tax_id is not null;

      UPDATE online_users
      SET    tax_id = REPLACE(:NEW.SSN,'-')
      where  find_key = PC_PERSON.acc_num(:NEW.PERS_ID)
      AND    tax_id IS NULL;
END IF;
*/
end;
/

alter trigger samqa.person_bf enable;

