create or replace function samqa.get_cursor (
    p_sql in varchar2
) return sys_refcursor is
    type l_cursor is ref cursor;  -- define weak REF CURSOR type
    l_sql_cur l_cursor;  -- declare cursor variable 
begin
    open l_sql_cur for  -- open cursor variable
     p_sql;

    return l_sql_cur;
end;
/


-- sqlcl_snapshot {"hash":"8235a1b63b6a99fdabef0e93eac581810318d845","type":"FUNCTION","name":"GET_CURSOR","schemaName":"SAMQA","sxml":""}