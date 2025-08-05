-- liquibase formatted sql
-- changeset SAMQA:1754374146402 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\test_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/test_email.sql:null:20e67eb006b53405efca973f9d52957d23691afd:create

create or replace procedure samqa.test_email as
begin
    pc_check_process.send_email_on_checks;
end;
/

