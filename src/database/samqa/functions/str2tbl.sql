create or replace function samqa.str2tbl (
    p_str in varchar2
) return varchar2_4000_tbl as
    l_str  long default p_str || ',';
    l_n    number;
    l_data varchar2_4000_tbl := varchar2_4000_tbl();
begin
    loop
        l_n := instr(l_str, ',');
        exit when ( nvl(l_n, 0) = 0 );
        l_data.extend;
        l_data(l_data.count) := ltrim(rtrim(substr(l_str, 1, l_n - 1)));

        l_str := substr(l_str, l_n + 1);
    end loop;

    return l_data;
end;
/


-- sqlcl_snapshot {"hash":"0f6282c296047605fc68b722d865ec53db9af959","type":"FUNCTION","name":"STR2TBL","schemaName":"SAMQA","sxml":""}