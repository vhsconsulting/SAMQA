create or replace editionable trigger samqa.bi_incident_history before
    insert on samqa.incident_history
    for each row
begin
    if :new.history_id is null then
        select
            incident_history_seq.nextval
        into :new.history_id
        from
            sys.dual;

    end if;
end;
/

alter trigger samqa.bi_incident_history enable;


-- sqlcl_snapshot {"hash":"bbf31784c79d5ab5a5dcfced9bd8ac77f6c528ca","type":"TRIGGER","name":"BI_INCIDENT_HISTORY","schemaName":"SAMQA","sxml":""}