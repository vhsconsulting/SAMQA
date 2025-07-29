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


-- sqlcl_snapshot {"hash":"68b8a98a8490e70d06edfbf5832e4f9b9cf8e7c9","type":"TRIGGER","name":"INCIDENT_DETAILS_T1","schemaName":"SAMQA","sxml":""}