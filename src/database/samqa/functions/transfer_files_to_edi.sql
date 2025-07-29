create or replace function samqa.transfer_files_to_edi (
    p_file_name  varchar2,
    p_source_dir varchar2,
    p_dest_dir   varchar2
) return number as

    l_job_exists  number;
    l_source_path varchar2(250);
    l_job_name    varchar2(500);
    l_run_jobs    number := 1;
begin
    l_job_name := 'TRANSFER_FILE_TO_EDI_JOB';
    while l_run_jobs = 1 loop
        l_run_jobs := 0;
        for run_jobs in (
            select
                1
            from
                user_scheduler_jobs
            where
                    job_name = l_job_name
                and state = 'RUNNING'
        ) loop
            l_run_jobs := 1;
        end loop;

        if nvl(l_run_jobs, 0) = 1 then
            dbms_session.sleep(3);
        end if;

    end loop;

    select
        count(*)
    into l_job_exists
    from
        user_scheduler_jobs
    where
        job_name = l_job_name;

    for x in (
        select
            directory_path
        from
            all_directories
        where
            directory_name = p_source_dir
    ) loop
        l_source_path := x.directory_path;
    end loop;

    if l_job_exists = 1 then
        dbms_scheduler.drop_job(job_name => l_job_name);
    end if;
    dbms_scheduler.create_job(
        job_name            => l_job_name,
        job_action          => '/u01/adminscripts/send_file_over_sftp.sh',
        job_type            => 'EXECUTABLE',
        number_of_arguments => 3, -- this will be the number of argument that this particular shell script will accept
        enabled             => false,
        auto_drop           => true,
        comments            => 'Run shell-script send_check_files.sh'
    );

-- define the arguments and their values for each argument (in this case there is only one)
    dbms_scheduler.set_job_argument_value(
        job_name          => l_job_name,
        argument_position => 1,
        argument_value    => p_file_name
    );

    dbms_scheduler.set_job_argument_value(
        job_name          => l_job_name,
        argument_position => 2,
        argument_value    => l_source_path
    );

    dbms_scheduler.set_job_argument_value(
        job_name          => l_job_name,
        argument_position => 3,
        argument_value    => p_dest_dir
    );

-- Since we couldn't enable it when creating it with arguments, enable it now
    dbms_scheduler.enable(l_job_name);

-- since we want this Job to execute now, we call run_job
    dbms_scheduler.run_job(job_name => l_job_name);

-- if we get here without an error, the job has completed so we can drop it
--DBMS_SCHEDULER.drop_job (job_name=> 'TRANSFER_FILE_TO_EDI_JOB');

    return 0; -- 0 means success

exception
    when others then
        dbms_output.put_line(sqlcode || sqlerrm);
        pc_log.log_batch_job_result(l_job_name, null, p_file_name
                                                      || ' '
                                                      || 'failed to transfer '
                                                      || sqlcode
                                                      || sqlerrm, null, sysdate,
                                    sysdate);

        return 1; -- anything other than 0 means a failure occurred
end;
/


-- sqlcl_snapshot {"hash":"ce2f3b814f4d0b2a2de67487a682577d2396dc6f","type":"FUNCTION","name":"TRANSFER_FILES_TO_EDI","schemaName":"SAMQA","sxml":""}