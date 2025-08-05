-- liquibase formatted sql
-- changeset SAMQA:1754374164692 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\aop_downsubscr_template_app_bi.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/aop_downsubscr_template_app_bi.sql:null:5e3bb9f80b8d6c08ab9ae124f773d45471a9d795:create

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

