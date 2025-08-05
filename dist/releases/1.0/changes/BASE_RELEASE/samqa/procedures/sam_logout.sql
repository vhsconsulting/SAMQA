-- liquibase formatted sql
-- changeset SAMQA:1754374146087 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\sam_logout.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/sam_logout.sql:null:2e8861a3cc2fe92e3b4bbcceed9d556cf18c9a80:create

create or replace procedure samqa.sam_logout as
begin
    app_users.sam_logout;
end;
/

