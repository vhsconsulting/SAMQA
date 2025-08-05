-- liquibase formatted sql
-- changeset SAMQA:1754374145274 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\purge_check.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/purge_check.sql:null:3da6d601eb19fceacd13daef131fcd240589a729:create

create or replace procedure samqa.purge_check (
    p_check_number in number
) is
    l_check_number number;
begin
    update checks
    set
        status = 'PURGED'
    where
        check_number = p_check_number;

end;
/

