-- liquibase formatted sql
-- changeset SAMQA:1754374165499 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\enterprise_census_t1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/enterprise_census_t1.sql:null:9b7e1f14e2945e185317aa8c75b51e5c10b73823:create

create or replace editionable trigger samqa.enterprise_census_t1 before
    insert or update on samqa.enterprise_census
    for each row
begin
-- Added this trigger for Ticket#8204 by Swamy on 03/02/2020
    if inserting then
        :new.creation_date := sysdate;
    end if;
exception
    when others then
        raise_application_error(-20001, 'TRIGGER ENTERPRISE_CENSUS ' || sqlerrm);
end;
/

alter trigger samqa.enterprise_census_t1 enable;

