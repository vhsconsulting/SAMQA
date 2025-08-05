-- liquibase formatted sql
-- changeset SAMQA:1754373927346 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_cursor.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_cursor.sql:null:8235a1b63b6a99fdabef0e93eac581810318d845:create

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

