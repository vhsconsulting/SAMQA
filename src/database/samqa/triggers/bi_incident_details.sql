create or replace editionable trigger samqa.bi_incident_details before
    insert on samqa.incident_details
    for each row
begin
    if :new.incident_id is null then
        select
            incident_details_seq.nextval
        into :new.incident_id
        from
            sys.dual;

    end if;
end;
/

alter trigger samqa.bi_incident_details enable;


-- sqlcl_snapshot {"hash":"d3b531eba1e5b881c407571ffa9ebc12ee05abe6","type":"TRIGGER","name":"BI_INCIDENT_DETAILS","schemaName":"SAMQA","sxml":""}