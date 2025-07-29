create or replace package body samqa.pc_external_scheduler as

    procedure ext_scheduler (
        p_job_name      in varchar2,
        p_script        in varchar2,
        p_argument      in varchar2,
        x_error_message out varchar2
    ) is
    begin
     -- delete if the job is found
        begin
            dbms_scheduler.drop_job(job_name => p_job_name);
        exception
            when others then
                null;
        end;

        dbms_scheduler.create_job(
            job_name            => p_job_name,
            job_type            => 'EXECUTABLE',
            job_action          => p_script,
            auto_drop           => false,
            number_of_arguments => 1,
            comments            => 'Run shell-script'
        );

        dbms_scheduler.set_job_argument_value(
            job_name          => p_job_name,
            argument_position => 1,
            argument_value    => p_argument
        );

        dbms_scheduler.enable(p_job_name);

--delete the program

--Purge the logfile for dbms_scheduler
   --  DBMS_SCHEDULER.PURGE_LOG;

    exception
        when others then
            x_error_message := sqlerrm;
    end ext_scheduler;

    function check_result (
        p_action in varchar2
    ) return varchar2 is
        l_file_name varchar2(3200);
        l_message   varchar2(3200);
    begin
        l_file_name := pc_debit_card.get_file_name(p_action, 'RESULT');
        if l_file_name is not null then
            l_message := 'ALERT!!!! Previous file for '
                         || pc_lookups.get_hra_bps_action(p_action)
                         || '  has not been processed yet.
                       Select Action and Choose Yes for "Do you want to process result" and submit. Once Result is processed
                       You can resubmit the file for processing new enrollments ';
        end if;

        return l_message;
    end check_result;

    procedure hra_bps_process (
        p_action         in varchar2,
        x_error_message  out varchar2,
        x_file_name      out varchar2,
        x_submitted_time out varchar2
    ) is
        l_job_name varchar2(3200);
    begin
        l_job_name := substr(p_action, 1, 6)
                      || to_char(sysdate, 'MMDDYYYYHHMISS');

        pc_log.log_error('hra_bps_process', 'job name' || l_job_name);
        ext_scheduler(l_job_name, './u01/app/oracle/oradata/metavante/samscript/hra_bps.sh', p_action, x_error_message);
        if x_error_message is null then
            for x in (
                select
                    file_name,
                    trunc(creation_date)                          creation_date,
                    to_char(creation_date, 'MM/DD/YYYY HH:MI:SS') cr_date
                from
                    metavante_files
                where
                    file_id = (
                        select
                            max(file_id)
                        from
                            metavante_files
                        where
                            file_action = p_action
                    )
            ) loop
                if x.creation_date <> trunc(sysdate) then
                    x_error_message := 'Error in running the job, Contact IT with this message ';
                end if;

                x_file_name := x.file_name;
                x_submitted_time := x.cr_date;
            end loop;
        end if;

    exception
        when others then
            x_error_message := sqlerrm;
    end hra_bps_process;

end pc_external_scheduler;
/


-- sqlcl_snapshot {"hash":"f5c8003b32e07173122e9ccc83315695f30e3a88","type":"PACKAGE_BODY","name":"PC_EXTERNAL_SCHEDULER","schemaName":"SAMQA","sxml":""}