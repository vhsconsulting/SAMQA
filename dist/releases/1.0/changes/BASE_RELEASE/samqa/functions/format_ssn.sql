-- liquibase formatted sql
-- changeset SAMQA:1754373927215 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\format_ssn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/format_ssn.sql:null:61b40ad57684e36110a98ab2a9883047320a2a19:create

create or replace function samqa.format_ssn (
    p_in in varchar2
) return varchar2 is
    t_ssn varchar2(12);
begin
    if instr(p_in, '-') = 0 then
        t_ssn := to_char(p_in, 'fm000g00g0000', 'nls_numeric_characters=.-');
    else
        t_ssn := p_in;
    end if;

    return t_ssn;
exception
    when others then
        return null;
end;
/

