-- liquibase formatted sql
-- changeset SAMQA:1754374164572 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\aop_config_biu.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/aop_config_biu.sql:null:6a4f0bc61605029941c2b559870d7a7b9fecdefd:create

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

