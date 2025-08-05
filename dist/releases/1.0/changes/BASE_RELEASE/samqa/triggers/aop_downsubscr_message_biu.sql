-- liquibase formatted sql
-- changeset SAMQA:1754374164654 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\aop_downsubscr_message_biu.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/aop_downsubscr_message_biu.sql:null:a5f7e10fafe38f6d25f04e3773082dc4d7f0870f:create

create or replace editionable trigger samqa.aop_downsubscr_message_biu before
    insert or update on samqa.aop_downsubscr_message
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

    :new.updated := sysdate;
    :new.updated_by := nvl(
        sys_context('APEX$SESSION', 'APP_USER'),
        user
    );
end aop_downsubscr_message_biu;
/

alter trigger samqa.aop_downsubscr_message_biu enable;

