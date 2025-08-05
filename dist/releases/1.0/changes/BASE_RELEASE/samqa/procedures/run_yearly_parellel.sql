-- liquibase formatted sql
-- changeset SAMQA:1754374146053 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\run_yearly_parellel.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/run_yearly_parellel.sql:null:d4137bc809018ff14fc4f5bb2a42c6d5053aefff:create

create or replace procedure samqa.run_yearly_parellel is
begin
    dbms_parallel_execute.create_task('yearly_activity');
    dbms_parallel_execute.create_chunks_by_number_col(
        task_name    => 'yearly_activity',
        table_owner  => 'SAM',
        table_name   => 'ACC_YEARLY_PAPER_STMT_V',
        table_column => 'ACC_ID',
        chunk_size   => 500
    );

    dbms_parallel_execute.run_task(
        task_name      => 'yearly_activity',
        sql_stmt       => 'begin PC_ACTIVITY_STATEMENT.PROCESS_YEARLY_ACTIVITY( :start_id, :end_id ); end;',
        language_flag  => dbms_sql.native,
        parallel_level => 4
    );

    dbms_parallel_execute.drop_task('yearly_activity');
end;
/

