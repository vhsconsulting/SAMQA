-- liquibase formatted sql
-- changeset SAMQA:1754373927074 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\dump_csv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/dump_csv.sql:null:dc09d4c1d3f384f4b8352539fb38d91ee1410a7e:create

create or replace function samqa.dump_csv (
    p_query     in varchar2,
    p_separator in varchar2 default ',',
    p_dir       in varchar2,
    p_filename  in varchar2
) return number
    authid current_user
is

    l_output      utl_file.file_type;
    l_thecursor   integer default dbms_sql.open_cursor;
    l_columnvalue varchar2(2000);
    l_status      integer;
    l_colcnt      number default 0;
    l_separator   varchar2(10) default '';
    l_cnt         number default 0;
    l_desc_tab    dbms_sql.desc_tab;
    l_cols        number;
    l_cursor      number;
begin 
 --  execute immediate 'alter session set nls_date_format = ''MM/DD/YYYY''';

    l_output := utl_file.fopen(p_dir, p_filename, 'w');
    dbms_sql.parse(l_thecursor, p_query, dbms_sql.native);
    dbms_sql.describe_columns(l_thecursor, l_cols, l_desc_tab);
    for i in 1..255 loop
        begin
            dbms_sql.define_column(l_thecursor, i, l_columnvalue, 2000);
            l_colcnt := i;
        exception
            when others then
                if ( sqlcode = -1007 ) then
                    exit;
                else
                    raise;
                end if;
        end;
    end loop;

    dbms_sql.define_column(l_thecursor, 1, l_columnvalue, 2000);
    l_status := dbms_sql.execute(l_thecursor);
    for i in 1..l_colcnt loop
        if i = 1 then
            utl_file.put(l_output,
                         l_desc_tab(i).col_name);
        else
            utl_file.put(l_output,
                         p_separator || l_desc_tab(i).col_name);
        end if;
        --set_column_width(i,30,'sheet1');

    end loop;

    utl_file.put_line(l_output, '');
    loop
        exit when ( dbms_sql.fetch_rows(l_thecursor) <= 0 );
        l_separator := '';
        for i in 1..l_colcnt loop
            dbms_sql.column_value(l_thecursor, i, l_columnvalue);
            utl_file.put(l_output, l_separator || l_columnvalue);
            l_separator := p_separator;
        end loop;

        utl_file.new_line(l_output);
        l_cnt := l_cnt + 1;
    end loop;

    dbms_sql.close_cursor(l_thecursor);
    utl_file.fclose(l_output); 
   --execute immediate 'alter session set nls_date_format = ''dd-mon-yyyy hh24:mi:ss''';
    return l_cnt;
end dump_csv;
/

