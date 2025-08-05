-- liquibase formatted sql
-- changeset SAMQA:1754373928119 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\is_number.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/is_number.sql:null:1f079a7f25518eec7a5090592df4173cab16a037:create

create or replace function samqa.is_number (
    str_in in varchar2
) return varchar2 is
    n number;
begin
    n := to_number ( str_in );
    return 'Y';
exception
    when value_error then
        return 'N';
end;
/

