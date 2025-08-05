-- liquibase formatted sql
-- changeset SAMQA:1754374164672 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\aop_downsubscr_output_biu.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/aop_downsubscr_output_biu.sql:null:0e80491baaa123ca15cee7fddc097ee10337c867:create

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

