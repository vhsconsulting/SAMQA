create or replace editionable trigger samqa.income_bef before
    insert or update on samqa.income
    referencing
            new as new
            old as old
    for each row
declare
    tmpvar number;
/******************************************************************************
   NAME:       INCOME_BEF
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        4/6/2009             1. Created this trigger.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     INCOME_BEF
      Sysdate:         4/6/2009
      Date and Time:   4/6/2009, 1:12:29 AM, and 4/6/2009 1:12:29 AM
      Username:         (set in TOAD Options, Proc Templates)
      Table Name:      INCOME (set in the "New PL/SQL Object" dialog)
      Trigger Options:  (set in the "New PL/SQL Object" dialog)
******************************************************************************/
begin
    if :new.contributor = 0 then
        :new.contributor := null;
    end if;

    if :new.list_bill = 0 then
        :new.list_bill := null;
    end if;

    if inserting then
        :new.created_by := get_user_id(v('APP_USER'));
        :new.creation_date := sysdate;
    end if;

    :new.last_updated_by := get_user_id(v('APP_USER'));
    :new.last_updated_date := sysdate;
exception
    when others then
       -- Consider logging the error and then re-raise
        raise;
end income_bef;
/

alter trigger samqa.income_bef enable;


-- sqlcl_snapshot {"hash":"4b324ba2c85227faadc277aa49d6480c9186aadf","type":"TRIGGER","name":"INCOME_BEF","schemaName":"SAMQA","sxml":""}