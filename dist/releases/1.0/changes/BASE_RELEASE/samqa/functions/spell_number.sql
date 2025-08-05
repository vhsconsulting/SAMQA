-- liquibase formatted sql
-- changeset SAMQA:1754373928520 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\spell_number.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/spell_number.sql:null:1c9ff9e283b921b5448170e8d924a82b05e6be5c:create

create or replace function samqa.spell_number (
    val number
) return varchar2 is
    sp varchar2(100);
begin
    if val > 0 then
        return ( initcap(to_char(to_date(val, 'SSSSS'), 'SSSSSSP')) );
    else
        return ( '' );
    end if;
end;
/

