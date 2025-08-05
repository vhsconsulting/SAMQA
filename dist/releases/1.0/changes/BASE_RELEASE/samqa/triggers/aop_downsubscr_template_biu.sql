-- liquibase formatted sql
-- changeset SAMQA:1754374164711 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\aop_downsubscr_template_biu.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/aop_downsubscr_template_biu.sql:null:65ee068bfa76f2a589ba32901b3b0537f705b527:create

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

