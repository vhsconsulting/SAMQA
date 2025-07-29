create or replace editionable trigger samqa.aop_downsubscr_log_biu before
    insert or update on samqa.aop_downsubscr_log
    for each row
begin
    if :new.id is null then
        :new.id := to_number ( sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' );
    end if;

    if inserting then
        :new.created := sysdate;
        :new.created_by := nvl(
            sys_context('APEX$SESSION', 'APP_USER'),
            user
        );
    end if;

end aop_downsubscr_log_biu;
/

alter trigger samqa.aop_downsubscr_log_biu enable;


-- sqlcl_snapshot {"hash":"b6fd7d548f98ce87f49c8690af6a70a465322023","type":"TRIGGER","name":"AOP_DOWNSUBSCR_LOG_BIU","schemaName":"SAMQA","sxml":""}