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


-- sqlcl_snapshot {"hash":"61b40ad57684e36110a98ab2a9883047320a2a19","type":"FUNCTION","name":"FORMAT_SSN","schemaName":"SAMQA","sxml":""}