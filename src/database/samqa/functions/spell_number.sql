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


-- sqlcl_snapshot {"hash":"1c9ff9e283b921b5448170e8d924a82b05e6be5c","type":"FUNCTION","name":"SPELL_NUMBER","schemaName":"SAMQA","sxml":""}