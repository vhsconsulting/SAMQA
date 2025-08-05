-- liquibase formatted sql
-- changeset SAMQA:1754373928128 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\is_valid_email.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/is_valid_email.sql:null:d4272e7ecfda04a353305ccb0c4e414264e24ae8:create

create or replace function samqa.is_valid_email (
    p_address varchar2
) return varchar2 is
    v_valid varchar2(1) := 'N';
begin
    if
        p_address like '_%@_%._%'
        and p_address not like '_%@%.%.%.%.%'
        and p_address not like '%@%@%'
    then
        v_valid := 'Y';
    else
        v_valid := 'N';
    end if;

    return v_valid;
end is_valid_email;
/

