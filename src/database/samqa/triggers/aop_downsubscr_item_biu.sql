create or replace editionable trigger samqa.aop_downsubscr_item_biu before
    insert or update on samqa.aop_downsubscr_item
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
end aop_downsubscr_item_biu;
/

alter trigger samqa.aop_downsubscr_item_biu enable;


-- sqlcl_snapshot {"hash":"2fc26c398014d51746981a7fb9a314ffc9046f48","type":"TRIGGER","name":"AOP_DOWNSUBSCR_ITEM_BIU","schemaName":"SAMQA","sxml":""}