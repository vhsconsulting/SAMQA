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


-- sqlcl_snapshot {"hash":"220b8e8bdeab21bbd7268ab3438cc39ae1955c72","type":"TRIGGER","name":"AOP_DOWNSUBSCR_MESSAGE_BIU","schemaName":"SAMQA","sxml":""}