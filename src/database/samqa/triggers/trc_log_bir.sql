create or replace editionable trigger samqa.trc_log_bir before
    insert on samqa.trc_log
    for each row
begin
    select
        trc_seq.nextval
    into :new.event_id
    from
        dual;

end;
/

alter trigger samqa.trc_log_bir enable;


-- sqlcl_snapshot {"hash":"ae3a5038d11407d5e03aa725fc47cfb16ffffc8b","type":"TRIGGER","name":"TRC_LOG_BIR","schemaName":"SAMQA","sxml":""}