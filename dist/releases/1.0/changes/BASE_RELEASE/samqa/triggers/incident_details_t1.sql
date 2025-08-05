-- liquibase formatted sql
-- changeset SAMQA:1754374165536 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\incident_details_t1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/incident_details_t1.sql:null:0e68593a02379b84bf1a6676053543fca5f915d9:create

create or replace editionable trigger samqa.incident_details_t1 before
    update on samqa.incident_details
    for each row
declare begin
    if updating then
         -- capture last_updated_date
        :new.last_update_date := sysdate;
        /*
        IF :NEW.DESCRIPTION <> :OLD.DESCRIPTION THEN
           INSERT
             INTO incident_history (incident_id, ticket_number,text,status,created_by,created_date,notes) 
           VALUES (:NEW.INCIDENT_ID, :NEW.TICKET_NUMBER,'Modified',:NEW.STATUS,:NEW.LAST_UPDATED_BY,sysdate, 'Prev desc :- '||:OLD.DESCRIPTION );          
        END IF;
        */
    end if;
exception
    when others then
        raise_application_error(-20001, 'TRIGGER INCIDENT_DETAILS_T1 ' || sqlerrm);
end incident_details_t1;
/

alter trigger samqa.incident_details_t1 enable;

