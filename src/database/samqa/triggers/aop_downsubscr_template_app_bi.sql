create or replace editionable trigger samqa.aop_downsubscr_template_app_bi before
    insert or update on samqa.aop_downsubscr_template_app
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
end aop_downsubscr_template_app_bi;
/

alter trigger samqa.aop_downsubscr_template_app_bi enable;


-- sqlcl_snapshot {"hash":"0c22b841edd3930e7d240104bb78215a30600452","type":"TRIGGER","name":"AOP_DOWNSUBSCR_TEMPLATE_APP_BI","schemaName":"SAMQA","sxml":""}