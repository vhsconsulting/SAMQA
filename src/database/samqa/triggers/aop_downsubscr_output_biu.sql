create or replace editionable trigger samqa.aop_downsubscr_output_biu before
    insert or update on samqa.aop_downsubscr_output
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

end aop_downsubscr_output_biu;
/

alter trigger samqa.aop_downsubscr_output_biu enable;


-- sqlcl_snapshot {"hash":"4dde51b051c284925028bc11e213a7f45fa39398","type":"TRIGGER","name":"AOP_DOWNSUBSCR_OUTPUT_BIU","schemaName":"SAMQA","sxml":""}