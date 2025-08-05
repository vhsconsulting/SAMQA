create or replace editionable trigger samqa.aop_downsubscr_template_biu before
    insert or update on samqa.aop_downsubscr_template
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
end aop_downsubscr_template_biu;
/

alter trigger samqa.aop_downsubscr_template_biu enable;


-- sqlcl_snapshot {"hash":"bb37f7939d305b0ff76c191ee491aaaab654e0f5","type":"TRIGGER","name":"AOP_DOWNSUBSCR_TEMPLATE_BIU","schemaName":"SAMQA","sxml":""}