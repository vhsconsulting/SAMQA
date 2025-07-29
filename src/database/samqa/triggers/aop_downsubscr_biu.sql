create or replace editionable trigger samqa.aop_downsubscr_biu before
    insert or update on samqa.aop_downsubscr
    for each row
begin
    if :new.id is null then
        $IF DBMS_DB_VERSION.VER_LE_11 $THEN

        :new.id := aop_downsubscr_seq.nextval;
        $ELSIF DBMS_DB_VERSION.VER_LE_12 $THEN
        :new.id := aop_downsubscr_seq.nextval;
        $ELSE
        :new.id := to_number(sys_guid(), 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX');
        $END
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
end aop_downsubscr_biu;
/

alter trigger samqa.aop_downsubscr_biu enable;


-- sqlcl_snapshot {"hash":"aa4cae9736d296db7cae05cdcd594fcafb6c8e5d","type":"TRIGGER","name":"AOP_DOWNSUBSCR_BIU","schemaName":"SAMQA","sxml":""}