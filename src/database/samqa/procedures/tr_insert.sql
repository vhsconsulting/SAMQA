create or replace procedure samqa.tr_insert (
    tname in varchar2,
    fname in varchar2,
    emesg out varchar2
) is

    l_str          long;
    l_piece        long;
    n              number;
    type lc_ref is ref cursor;
    lc_seq_cur     lc_ref;
    lc_column_cur  lc_ref;
    seq_sql        varchar2(2000);
    create_seq_sql varchar2(2000);
    column_sql     varchar2(2000);
    alter_col_sql  varchar2(2000);
    column_count   number := 0;
    seq_name       varchar2(200);
    owner          varchar2(200);
    pk_name        varchar2(200);
    trigger_sql    varchar2(2000);
    seq_exist      varchar2(1);
begin

/** Sequence Existence Checking **/

    seq_sql := 'SELECT column_name, sequence_name,seq_exist, ''CREATE SEQUENCE ''||sequence_name '
               || 'FROM   (SELECT B.COLUMN_NAME, SUBSTR(B.COLUMN_NAME,1,4)||''_SEQ'' sequence_name '
               || '	     , (SELECT ''X'' FROM ALL_SEQUENCES WHERE SEQUENCE_NAME = SUBSTR(B.COLUMN_NAME,1,4)||''_SEQ'') seq_exist '
               || '                  FROM   SYS.ALL_CONSTRAINTS  A'
               || '                      ,  SYS.ALL_CONS_COLUMNS B'
               || '                 WHERE   B.TABLE_NAME = :1'
               || '                   AND   A.CONSTRAINT_NAME = B.CONSTRAINT_NAME'
               || '                   AND   CONSTRAINT_TYPE=''P'') ';

    open lc_seq_cur for seq_sql
        using tname;

    loop
        fetch lc_seq_cur into
            pk_name,
            seq_name,
            seq_exist,
            create_seq_sql;
        exit when lc_seq_cur%notfound;
    end loop;

    close lc_seq_cur;
    l_str := seq_sql || chr(10);
    loop
        exit when l_str is null;
        n := instr(l_str,
                   chr(10));
        l_piece := substr(l_str, 1, n - 1);
        l_str := substr(l_str, n + 1);
        loop
            exit when l_piece is null;
            dbms_output.put_line(substr(l_piece, 1, 250));
            l_piece := substr(l_piece, 251);
        end loop;

    end loop;

/** Creating Sequence  **/
    if
        create_seq_sql is not null
        and seq_exist is null
    then
        execute immediate create_seq_sql;
    end if;

/** Created by and Date created column existence checking **/

    column_sql := 'SELECT cnt, ''ALTER TABLE '' || table_name || '' ADD ''|| col_name || '
                  || '         DECODE(COL_NAME, ''CREATED_BY''   ,'' VARCHAR2(30)'' '
                  || '                     , ''DATE_CREATED'' , '' DATE '') '
                  || 'FROM (SELECT table_name, '
                  || '       DECODE(column_name, ''CREATED_BY'',''DATE_CREATED'',''DATE_CREATED'',''CREATED_BY'') col_name,'
                  || '       COUNT(COLUMN_NAME) OVER (PARTITION BY TABLE_NAME) CNT '
                  || ' FROM   all_tab_columns '
                  || 'WHERE  column_name IN (''CREATED_BY'',''DATE_CREATED'') '
                  || 'AND    table_name = :2) '
                  || 'WHERE col_name IS NOT NULL';

    l_str := column_sql || chr(10);
    loop
        exit when l_str is null;
        n := instr(l_str,
                   chr(10));
        l_piece := substr(l_str, 1, n - 1);
        l_str := substr(l_str, n + 1);
        loop
            exit when l_piece is null;
            dbms_output.put_line(substr(l_piece, 1, 250));
            l_piece := substr(l_piece, 251);
        end loop;

    end loop;

    open lc_column_cur for column_sql
        using tname;

    loop
        fetch lc_column_cur into
            column_count,
            alter_col_sql;
        exit when lc_column_cur%notfound;
    end loop;
    close lc_column_cur;
    dbms_output.put_line(column_count);
    if nvl(column_count, 0) = 0 then
        alter_col_sql := 'ALTER TABLE '
                         || tname
                         || ' ADD (created_by VARCHAR2(30) NOT NULL,date_created DATE NOT NULL) ';
    end if;

    if
        column_count in ( 0, 1 )
        and alter_col_sql is not null
    then
        execute immediate alter_col_sql;
    end if;

    select
        user
    into owner
    from
        dual;

    trigger_sql := 'CREATE OR REPLACE TRIGGER '
                   || 'DEVEL'
                   || '.BI_'
                   || substr(pk_name, 1, 4)
                   || '_TRG'
                   || ' BEFORE INSERT '
                   || ' ON '
                   || tname
                   || ' FOR EACH ROW '
                   || '  BEGIN '
                   || '    IF :NEW.'
                   || pk_name
                   || ' IS NULL THEN '
                   || '      SELECT '
                   || seq_name
                   || '.NEXTVAL '
                   || '        INTO :NEW.'
                   || pk_name
                   || '        FROM dual; '
                   || '    END IF; '
                   || '    :new.created_by := '
                   || fname
                   || ';'
                   || '    :new.date_created := SYSDATE; '
                   || 'END;';

    l_str := trigger_sql || chr(10);
    loop
        exit when l_str is null;
        n := instr(l_str,
                   chr(10));
        l_piece := substr(l_str, 1, n - 1);
        l_str := substr(l_str, n + 1);
        loop
            exit when l_piece is null;
            dbms_output.put_line(substr(l_piece, 1, 250));
            l_piece := substr(l_piece, 251);
        end loop;

    end loop;

    execute immediate trigger_sql;
exception
    when others then
        emesg := sqlerrm;
end;
/


-- sqlcl_snapshot {"hash":"70216e3a13a29d4cd6782be9b1f65c8c732a31b0","type":"PROCEDURE","name":"TR_INSERT","schemaName":"SAMQA","sxml":""}