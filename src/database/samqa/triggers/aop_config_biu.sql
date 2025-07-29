create or replace editionable trigger samqa.aop_config_biu before
    insert or update on samqa.aop_config
    for each row
begin
    if :new.id is null then
        :new.id := 1;
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
end aop_config_biu;
/

alter trigger samqa.aop_config_biu enable;


-- sqlcl_snapshot {"hash":"20b1b16226d91cc01c4c030cf7f976a2be1b7231","type":"TRIGGER","name":"AOP_CONFIG_BIU","schemaName":"SAMQA","sxml":""}