create or replace procedure samqa.run_bal_parellel is
begin
    dbms_parallel_execute.create_task('ER_BALANCE');
    dbms_parallel_execute.create_chunks_by_number_col(
        task_name    => 'ER_BALANCE',
        table_owner  => 'SAM',
        table_name   => 'FSA_HRA_EMPLOYERS_V',
        table_column => 'ENTRP_ID',
        chunk_size   => 50
    );

    dbms_parallel_execute.run_task(
        task_name      => 'ER_BALANCE',
        sql_stmt       => 'begin PC_EMPLOYER_FIN.PROCESS_BAL_PARELLEL( :start_id, :end_id ); end;',
        language_flag  => dbms_sql.native,
        parallel_level => 4
    );

    dbms_parallel_execute.drop_task('ER_BALANCE');
end;
/


-- sqlcl_snapshot {"hash":"aebe19b5c1ae9861ca726da6c550561ef962ff3c","type":"PROCEDURE","name":"RUN_BAL_PARELLEL","schemaName":"SAMQA","sxml":""}