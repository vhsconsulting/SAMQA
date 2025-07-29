create or replace procedure samqa.create_view_trigger (
    view_name in varchar2,
    errmsg    out varchar2
) as
    l_view_sql varchar2(32000);
    insert_excp exception;
begin
    execute immediate 'TRUNCATE TABLE view_dependencies';
    l_view_sql := 'INSERT INTO  view_dependencies  '
                  || 'WITH view_tables AS '
                  || '(select referenced_owner, referenced_name from dba_dependencies '
                  || 'start with name = '''
                  || view_name
                  || ''' connect by prior referenced_owner = owner and prior referenced_name = name '
                  || 'and prior referenced_type = type and type = ''VIEW''), '
                  || 'view_tree AS '
                  || '(SELECT a.table_name, a.constraint_name , a.r_constraint_name '
                  || '	, NULL r_table_name, NULL join_type  , d.column_name, NULL r_column_name '
                  || ' , DECODE(a.constraint_type,''P'',''PRIMARY KEY'') constraint_type '
                  || 'FROM   user_constraints a,  view_tables b,  user_cons_columns d '
                  || 'where  a.table_name  = b.referenced_name  '
                  || 'and    a.constraint_type  = ''P'' '
                  || 'and    d.constraint_name = a.constraint_name '
                  || 'and    a.table_name in ( select referenced_name from view_tables) '
                  || 'UNION ALL  '
                  || 'SELECT a.table_name, a.constraint_name , a.r_constraint_name   '
                  || ', c.table_name r_table_name, CASE WHEN a.table_name = c.table_name THEN  '
                  || '  ''SELFJOIN'' 	ELSE  ''EQUIJOIN'' END join_type,d.column_name,e.column_name r_column_name  '
                  || ' , DECODE(a.constraint_type,''R'',''FOREIGN KEY'') constraint_type '
                  || 'FROM  user_constraints a,view_tables b,	user_constraints c,user_cons_columns d, '
                  || 'user_cons_columns e '
                  || 'where  a.table_name  = b.referenced_name  '
                  || 'and    a.constraint_type  = ''R''  '
                  || 'and    a.r_constraint_name = c.constraint_name  '
                  || 'and    a.constraint_name = d.constraint_name  '
                  || 'and    e.constraint_name = a.r_constraint_name  '
                  || 'and    a.table_name <> c.table_name  '
                  || 'and    c.table_name in ( select referenced_name from view_tables))  '
                  || 'SELECT table_name , constraint_name , r_constraint_name , join_type '
                  || ' , constraint_type, column_name, count(r_constraint_name) over (partition by table_name) table_order,r_column_name '
                  || 'FROM   view_tree  '
                  || 'ORDER BY count(r_constraint_name) over (partition by table_name) ';

    execute immediate l_view_sql;
exception
    when insert_excp then
        raise;
    when others then
        errmsg := sqlerrm;
end;
/


-- sqlcl_snapshot {"hash":"dfc941f797a5926341fd715579edd8ff9904768d","type":"PROCEDURE","name":"CREATE_VIEW_TRIGGER","schemaName":"SAMQA","sxml":""}