create or replace package body samqa.pc_scheduled_jobs as
/*SELECT * FROM dba_scheduler_programs;

SELECT * FROM dba_scheduler_jobs where owner = 'NEWCOBRA'
and job_name = 'COBRA_MONTHLY_INVOICE_PGM_JOB'

BEGIN
  -- Enable programs and jobs.
  DBMS_SCHEDULER.enable (name => 'NEWCOBRA.COBRA_MONTHLY_INVOICE_PGM_JOB');
end;*/

    g_metavante_folder    constant varchar2(250) := '/edi/metavante/out';
    g_adminisource_folder constant varchar2(250) := '/edi/cnb_checks/out';
    g_meta_source_path    constant varchar2(250) := 'DEBIT_CARD_DIR';
    g_admin_source_path   constant varchar2(250) := 'CHECKS_DIR';
    g_nacha_folder        constant varchar2(250) := '/edi/cnb/out';
    g_nacha_source_path   constant varchar2(250) := 'BANK_SERV_DIR';

    procedure create_program_for_proc (
        p_program_name   in varchar2,
        p_procedure_name in varchar2
    ) is
    begin
        dbms_scheduler.create_program(
            program_name        => p_program_name,
            program_type        => 'STORED_PROCEDURE',
            program_action      => p_procedure_name,
            number_of_arguments => 0,
            enabled             => false,
            comments            => 'Programfor  stored procedure ' || p_procedure_name
        );

        dbms_scheduler.enable(name => p_program_name);
    end create_program_for_proc;

    procedure create_job_for_proc (
        p_program_name  in varchar2,
        p_schedule_hour in number,
        p_schedule_min  in number
    ) is
    begin
        dbms_scheduler.create_job(
            job_name        => p_program_name || '_JOB',
            program_name    => p_program_name,
            start_date      => systimestamp,
            repeat_interval => 'freq=daily; byhour='
                               || p_schedule_hour
                               || '; byminute='
                               || p_schedule_min
                               || '; bysecond=0;',
            end_date        => null,
            enabled         => true,
            comments        => 'Job defined by existing program and inline schedule for ' || p_program_name
        );
    end create_job_for_proc;

    procedure run_job (
        p_program_name in varchar2
    ) is
    begin
        dbms_scheduler.run_job(
            job_name            => p_program_name || '_JOB',
            use_current_session => true
        );
    end run_job;

    procedure create_schedulers (
        p_job_name varchar2 default null
    ) as
    begin
        if p_job_name is null then
            for i in (
                select
                    *
                from
                    job_schedulers
                where
                    upper(job_name) not in (
                        select
                            job_name
                        from
                            all_scheduler_jobs
                    )
            ) loop
                begin
                    dbms_scheduler.create_job(
                        job_name        => i.job_name,
                        job_type        => i.job_type,
                        job_action      => i.job_action,
                        start_date      => i.start_date,
                        repeat_interval => i.repeat_interval,
                        comments        => i.comments,
                        enabled         => true
                    );

                exception
                    when others then
                        pc_log.log_batch_job_result('CREATE_SCHEDULERS', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
                end;
            end loop;

        else
            for i in (
                select
                    *
                from
                    job_schedulers
                where
                    upper(job_name) not in (
                        select
                            job_name
                        from
                            all_scheduler_jobs
                    )
                    and upper(job_name) = upper(p_job_name)
            ) loop
                begin
                    dbms_scheduler.create_job(
                        job_name        => i.job_name,
                        job_type        => i.job_type,
                        job_action      => i.job_action,
                        start_date      => i.start_date,
                        repeat_interval => i.repeat_interval,
                        comments        => i.comments,
                        enabled         => true
                    );

                exception
                    when others then
                        pc_log.log_batch_job_result('CREATE_SCHEDULERS', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
                end;
            end loop;
        end if;
    end create_schedulers;

    procedure drop_schedulers (
        p_job_name varchar2 default null
    ) as
    begin
        if p_job_name is null then
            for i in (
                select
                    job_name
                from
                    job_schedulers
                where
                    upper(job_name) in (
                        select
                            job_name
                        from
                            all_scheduler_jobs
                    )
            ) loop
                begin
                    dbms_scheduler.drop_job(job_name => i.job_name);
                exception
                    when others then
                        pc_log.log_batch_job_result('DROP_SCHEDULERS', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
                end;
            end loop;

        else
            begin
                dbms_scheduler.drop_job(job_name => p_job_name);
            exception
                when others then
                    pc_log.log_batch_job_result('DROP_SCHEDULERS', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
            end;
        end if;
    end drop_schedulers;

    procedure run_hra_fsa_card_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.hra_fsa_card_creation(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_hra_fsa_card_creation_job', null, l_file_name
                                                                                   || ' '
                                                                                   || 'successfully generated and sent to metavante',
                                                                                   null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_fsa_card_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_hra_fsa_card_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_fsa_card_creation_job;

    procedure run_hra_fsa_ee_card_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.hra_fsa_ee_card_creation(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_hra_fsa_ee_card_creation_job', null, l_file_name
                                                                                      || ' '
                                                                                      || 'successfully generated and sent to metavante'
                                                                                      , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_fsa_ee_card_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_hra_fsa_ee_card_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_fsa_ee_card_creation_job;

    procedure run_card_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.card_creation(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_card_creation_job', null, l_file_name
                                                                           || ' '
                                                                           || 'successfully generated and sent to metavante', null, l_start_date
                                                                           ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_card_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_card_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_card_creation_job;

    procedure run_custom_card_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.custom_card_creation(l_file_name);
        commit;
        dbms_output.put_line('l_file_name ' || l_file_name);
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_custom_card_creation_job', null, l_file_name
                                                                                  || ' '
                                                                                  || 'successfully generated and sent to metavante', null
                                                                                  , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_custom_card_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_custom_card_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_custom_card_creation_job;

    procedure run_card_request_history_job is
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.card_request_history(null, 'SUBSCRIBER');
        commit;
        pc_debit_card.card_request_history(null, 'DEPENDANT');
        commit;
    exception
        when others then
            pc_log.log_batch_job_result('run_card_request_history_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_card_request_history_job;

    procedure run_hra_er_creation_job is
        l_file_name    varchar2(250);
        l_return_code  number;
        l_start_date   date;
        l_batch_number number;
    begin
        l_start_date := sysdate;
        pc_debit_card.employer_demg(null, l_file_name);
        commit;
        l_batch_number := batch_num_seq.nextval;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_hra_er_creation_job', null, l_file_name
                                                                             || ' '
                                                                             || 'successfully generated and sent to metavante', null,
                                                                             l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_er_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_hra_er_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_er_creation_job;

    procedure run_er_plan_update_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.employer_plan_update(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_er_plan_update_job', null, l_file_name
                                                                            || ' '
                                                                            || 'successfully generated and sent to metavante', null, l_start_date
                                                                            ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_er_plan_update_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_er_plan_update_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_er_plan_update_job;

    procedure run_hra_er_creation_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('EMPLOYER_DEMOG', 'RESULT');
        begin
            if l_file_name is null then
                raise no_file_found;
            elsif
                l_file_name is not null
                and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
            then
                raise file_does_not_exist;
            else
                pc_debit_card.process_result(l_file_name, l_error_message);
                commit;
                pc_log.log_batch_job_result('run_hra_er_creation_result_job', null, l_file_name || ' Processing Completed Successfully - EMPLOYER_DEMOG'
                , null, l_start_date,
                                            sysdate);

            end if;
        exception
            when no_file_found then
                pc_log.log_batch_job_result('run_hra_er_creation_result_job', -20001, 'EMPLOYER_DEMOG File Not Found in METAVANTE table'
                , dbms_utility.format_error_backtrace);
            when file_does_not_exist then
                pc_log.log_batch_job_result('run_hra_er_creation_result_job', -20002, 'EMPLOYER_DEMOG File '
                                                                                      || l_file_name
                                                                                      || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                      );
            when others then
                pc_log.log_batch_job_result('run_hra_er_creation_result_job', sqlcode, 'EMPLOYER_DEMOG ' || sqlerrm, dbms_utility.format_error_backtrace
                );
        end;

        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('ER_PLAN_UPDATE', 'RESULT');
        begin
            if l_file_name is null then
                raise no_file_found;
            elsif
                l_file_name is not null
                and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
            then
                raise file_does_not_exist;
            else
                l_start_date := sysdate;
                pc_debit_card.process_result(l_file_name, l_error_message);
                commit;
                pc_log.log_batch_job_result('run_hra_er_creation_result_job', null, l_file_name || ' Processing Completed Successfully - ER_PLAN_UPDATE'
                , null, l_start_date,
                                            sysdate);

            end if;
        exception
            when no_file_found then
                pc_log.log_batch_job_result('run_hra_er_creation_result_job', -20001, 'ER_PLAN_UPDATE File Not Found in METAVANTE table'
                , dbms_utility.format_error_backtrace);
            when file_does_not_exist then
                pc_log.log_batch_job_result('run_hra_er_creation_result_job', -20002, 'ER_PLAN_UPDATE File '
                                                                                      || l_file_name
                                                                                      || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                      );
            when others then
                pc_log.log_batch_job_result('run_hra_er_creation_result_job', sqlcode, 'ER_PLAN_UPDATE ' || sqlerrm, dbms_utility.format_error_backtrace
                );
        end;

    end run_hra_er_creation_result_job;

    procedure run_hra_ee_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.hra_ee_creation(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_hra_ee_creation_job', null, l_file_name
                                                                             || ' '
                                                                             || 'successfully generated and sent to metavante', null,
                                                                             l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_ee_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_hra_ee_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_ee_creation_job;

    procedure run_hra_ee_creation_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('HRA_EE_CREATION', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            l_start_date := sysdate;
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_hra_ee_creation_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_ee_creation_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_hra_ee_creation_result_job', -20002, 'File '
                                                                                  || l_file_name
                                                                                  || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                  );
        when others then
            pc_log.log_batch_job_result('run_hra_ee_creation_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_ee_creation_result_job;

    procedure run_terminate_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.terminate(null, l_file_name);
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_terminate_job', null, l_file_name
                                                                       || ' '
                                                                       || 'successfully generated and sent to metavante', null, l_start_date
                                                                       ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_terminate_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_terminate_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_terminate_job;

    procedure run_hra_fsa_terminate_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.hra_fsa_terminate(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_hra_fsa_terminate_job', null, l_file_name
                                                                               || ' '
                                                                               || 'successfully generated and sent to metavante', null
                                                                               , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_fsa_terminate_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_hra_fsa_terminate_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_fsa_terminate_job;

    procedure run_lost_stolen_job is
        l_file_name    varchar2(250);
        l_if_file_name varchar2(250);
        l_return_code  number;
        l_start_date   date;
    begin
        l_start_date := sysdate;
        pc_debit_card.lost_stolen(null, l_file_name, l_if_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_lost_stolen_job', null, l_file_name
                                                                         || ' '
                                                                         || 'successfully generated and sent to metavante', null, l_start_date
                                                                         ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_lost_stolen_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_lost_stolen_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_lost_stolen_job;

    procedure run_lost_stolen_create_card_job is
        l_file_name    varchar2(250);
        l_if_file_name varchar2(250);
        l_return_code  number;
        l_start_date   date;
    begin
        l_start_date := sysdate;
        pc_debit_card.lost_stolen_reorder(null, l_file_name, l_if_file_name);
        if l_if_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_if_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_lost_stolen_create_card_job', null, l_if_file_name
                                                                                     || ' '
                                                                                     || 'successfully generated and sent to metavante'
                                                                                     , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_lost_stolen_create_card_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_lost_stolen_create_card_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_lost_stolen_create_card_job;

-- #all export
    procedure run_export_em_request_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.request_card_export(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_export_EM_request_job', null, l_file_name
                                                                               || ' '
                                                                               || 'successfully generated and sent to metavante', null
                                                                               , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_export_EM_request_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_export_EM_request_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_export_em_request_job;

    procedure run_process_em_export_job is

        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_status        varchar2(30);
        l_return_code   number;
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('EM', 'EXPORT');
        if l_file_name is null then
            raise no_file_found;
        else
            pc_debit_card.update_card_details(l_status, l_error_message, l_file_name);
            commit;
            pc_log.log_batch_job_result('run_process_EM_export_job', null, l_file_name || ' Processing Completed Successfully', null,
            l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_process_EM_export_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_process_EM_export_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_process_em_export_job;

    procedure run_demographic_update_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.demographic_update(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_demographic_update_job', null, l_file_name
                                                                                || ' '
                                                                                || 'successfully generated and sent to metavante', null
                                                                                , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_demographic_update_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_demographic_update_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_demographic_update_job;

-- # export files
    procedure run_unsuspend_job is
        l_file_name    varchar2(250);
        l_return_code  number;
        l_start_date   date;
        l_hra_fsa_file varchar2(250);
    begin
        l_start_date := sysdate;
        pc_debit_card.unsuspend(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_unsuspend_job', null, l_file_name
                                                                       || ' '
                                                                       || '  HSA successfully generated and sent to metavante', null,
                                                                       l_start_date,
                                            sysdate);

            end if;

        end if;

        pc_debit_card.hrafsa_unsuspend(l_hra_fsa_file);
        commit;
        if l_hra_fsa_file is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_hra_fsa_file, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_unsuspend_job', null, l_hra_fsa_file
                                                                       || ' '
                                                                       || ' HRA/FSA successfully generated and sent to metavante', null
                                                                       , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_unsuspend_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_unsuspend_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_unsuspend_job;

    procedure run_suspend_job is
        l_file_name         varchar2(250);
        l_return_code       number;
        l_start_date        date;
        l_fsa_hra_file_name varchar2(250);
    begin
        l_start_date := sysdate;
        pc_debit_card.suspend_card(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_suspend_job', null, l_file_name
                                                                     || ' '
                                                                     || 'successfully generated and sent to metavante', null, l_start_date
                                                                     ,
                                            sysdate);

            end if;

        end if;

        l_start_date := sysdate;
        pc_debit_card.hrafsa_suspend_card(l_fsa_hra_file_name);
        commit;
        if l_fsa_hra_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_fsa_hra_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_suspend_job', null, l_fsa_hra_file_name
                                                                     || ' '
                                                                     || 'successfully generated and sent to metavante', null, l_start_date
                                                                     ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_suspend_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_suspend_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_suspend_job;

-- # process all the payment related information
    procedure run_deposit_payment_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.card_adjustments(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_deposit_payment_job', null, l_file_name
                                                                             || ' '
                                                                             || 'successfully generated and sent to metavante', null,
                                                                             l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_deposit_payment_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_deposit_payment_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_deposit_payment_job;

    procedure run_payment_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.payment_adjustments(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_payment_job', null, l_file_name
                                                                     || ' '
                                                                     || 'successfully generated and sent to metavante', null, l_start_date
                                                                     ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_payment_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_payment_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_payment_job;

    procedure run_hra_annual_election_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.annual_election(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_hra_annual_election_job', null, l_file_name
                                                                                 || ' '
                                                                                 || 'successfully generated and sent to metavante', null
                                                                                 , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_annual_election_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace)
            ;
        when others then
            pc_log.log_batch_job_result('run_hra_annual_election_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_annual_election_job;

    procedure run_hra_deposits_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.hra_deposits(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_hra_deposits_job', null, l_file_name
                                                                          || ' '
                                                                          || 'successfully generated and sent to metavante', null, l_start_date
                                                                          ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_deposits_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_hra_deposits_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_deposits_job;

    procedure run_claim_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.hra_fsa_claims(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_claim_job', null, l_file_name
                                                                   || ' '
                                                                   || 'successfully generated and sent to metavante', null, l_start_date
                                                                   ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_claim_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_claim_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_claim_job;

-- #process result files
    procedure run_acc_num_change_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('ACC_NUM_UPDATE', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_acc_num_change_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_acc_num_change_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_acc_num_change_result_job', -20002, 'File '
                                                                                 || l_file_name
                                                                                 || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                 );
        when others then
            pc_log.log_batch_job_result('run_acc_num_change_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_acc_num_change_result_job;

    procedure run_lost_stolen_result_job is

        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
        no_file_found exception;
        file_does_not_exist exception;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('LOST', 'RESULT');
        dbms_output.put_line('l_file_name ' || l_file_name);
        if l_file_name is null then
            dbms_output.put_line('l_file_name ' || l_file_name);
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_lost_stolen_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_lost_stolen_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_lost_stolen_result_job', -20002, 'File '
                                                                              || l_file_name
                                                                              || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                              );
        when others then
            pc_log.log_batch_job_result('run_lost_stolen_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_lost_stolen_result_job;

    procedure run_card_creation_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('CARD_CREATION', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_card_creation_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_card_creation_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_card_creation_result_job', -20002, 'File '
                                                                                || l_file_name
                                                                                || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                );
        when others then
            pc_log.log_batch_job_result('run_card_creation_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_card_creation_result_job;

    procedure run_address_update_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('ADDRESS_UPDATE', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_address_update_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_address_update_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_address_update_result_job', -20002, 'File '
                                                                                 || l_file_name
                                                                                 || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                 );
        when others then
            pc_log.log_batch_job_result('run_address_update_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_address_update_result_job;

    procedure run_terminate_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        for i in (
            select
                'TERMINATION' file_action
            from
                dual
            union
            select
                'HRA_FSA_PLAN_TERMINATION' file_action
            from
                dual
        ) loop
            l_start_date := sysdate;
            l_file_name := pc_debit_card.get_file_name(i.file_action, 'RESULT');
            begin
                if l_file_name is null then
                    raise no_file_found;
                elsif
                    l_file_name is not null
                    and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
                then
                    raise file_does_not_exist;
                else
                    pc_debit_card.process_result(l_file_name, l_error_message);
                    commit;
                    pc_log.log_batch_job_result('run_terminate_result_job', null, l_file_name || ' Processing Completed Successfully'
                    , null, l_start_date,
                                                sysdate);

                end if;
            exception
                when no_file_found then
                    pc_log.log_batch_job_result('run_terminate_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
                    );
                when file_does_not_exist then
                    pc_log.log_batch_job_result('run_terminate_result_job', -20002, 'File '
                                                                                    || l_file_name
                                                                                    || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                    );
                when others then
                    pc_log.log_batch_job_result('run_terminate_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
            end;

        end loop;
    exception
        when others then
            pc_log.log_batch_job_result('run_terminate_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_terminate_result_job;

    procedure run_unsuspend_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('UNSUSPEND', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_unsuspend_result_job', null, l_file_name || ' Processing Completed Successfully', null, l_start_date
            ,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_unsuspend_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_suspend_result_job', -20002, 'File '
                                                                          || l_file_name
                                                                          || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                          );
        when others then
            pc_log.log_batch_job_result('run_unsuspend_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_unsuspend_result_job;

    procedure run_deposit_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('DEPOSIT', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_deposit_result_job', null, l_file_name || ' Processing Completed Successfully', null, l_start_date
            ,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_deposit_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_deposit_result_job', -20002, 'File '
                                                                          || l_file_name
                                                                          || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                          );
        when others then
            pc_log.log_batch_job_result('run_deposit_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_deposit_result_job;

    procedure run_payment_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('PAYMENT', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_payment_result_job', null, l_file_name || ' Processing Completed Successfully', null, l_start_date
            ,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_payment_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_payment_result_job', -20002, 'File '
                                                                          || l_file_name
                                                                          || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                          );
        when others then
            pc_log.log_batch_job_result('run_payment_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_payment_result_job;

    procedure run_suspend_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('SUSPEND', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_suspend_result_job', null, l_file_name || ' Processing Completed Successfully', null, l_start_date
            ,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_suspend_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_suspend_result_job', -20002, 'File '
                                                                          || l_file_name
                                                                          || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                          );
        when others then
            pc_log.log_batch_job_result('run_suspend_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_suspend_result_job;

    procedure run_process_all_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        for i in (
            select
                replace(b.file_name, 'mbi', 'res') file_name,
                instr(
                    upper(b.file_name),
                    'EMPLOYER_DEMOG'
                )                                  employer_demog,
                instr(
                    upper(b.file_name),
                    'ER_PLAN_UPDATE'
                )                                  er_plan_update,
                instr(
                    upper(b.file_name),
                    'DEP_'
                )                                  dep
            from
                metavante_files b
            where
                file_name like 'MB%'
                and file_name not like '%EN%'
                and file_name not like '%EM%'
                and file_name not like '%EC%'
                and nvl(b.result_flag, 'N') = 'N'
        ) loop
            begin
                if file_exists(i.file_name, 'DEBIT_CARD_DIR') = 'FALSE' then
                    raise file_does_not_exist;
                else
                    if i.employer_demog <> 0 then
                        pc_debit_card.process_er_result(i.file_name, l_error_message);
                    elsif i.er_plan_update <> 0 then
                        pc_debit_card.process_er_result(i.file_name, l_error_message);
                    elsif i.dep <> 0 then
                        pc_debit_card.process_dependant_result(i.file_name, l_error_message);
                    else
                        pc_debit_card.process_result(i.file_name, l_error_message);
                    end if;

                    commit;
                    pc_log.log_batch_job_result('run_process_all_result_job', null, i.file_name || ' Processing Completed Successfully'
                    , null, l_start_date,
                                                sysdate);

                end if;

            exception
                when no_file_found then
                    pc_log.log_batch_job_result('run_process_all_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
                    );
                when file_does_not_exist then
                    pc_log.log_batch_job_result('run_process_all_result_job', -20002, 'File '
                                                                                      || i.file_name
                                                                                      || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                      );
                when others then
                    pc_log.log_batch_job_result('run_process_all_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
            end;
        end loop;

    exception
        when others then
            pc_log.log_batch_job_result('run_process_all_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_process_all_result_job;

    procedure run_process_dep_all_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        for i in (
            select distinct
                b.file_action
            from
                lookups         a,
                metavante_files b
            where
                    a.lookup_code = b.file_action
                and lookup_name = 'BPS_DEP_ACTION'
                and nvl(b.result_flag, 'N') = 'N'
        ) loop
            begin
                l_file_name := pc_debit_card.get_file_name(i.file_action, 'RESULT');
                if l_file_name is null then
                    raise no_file_found;
                elsif
                    l_file_name is not null
                    and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
                then
                    raise file_does_not_exist;
                else
                    pc_debit_card.process_result(l_file_name, l_error_message);
                    commit;
                    pc_log.log_batch_job_result('run_process_dep_all_result_job', null, l_file_name || ' Processing Completed Successfully'
                    , null, l_start_date,
                                                sysdate);

                end if;

            exception
                when no_file_found then
                    pc_log.log_batch_job_result('run_process_dep_all_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
                    );
                when file_does_not_exist then
                    pc_log.log_batch_job_result('run_process_dep_all_result_job', -20002, 'File '
                                                                                          || l_file_name
                                                                                          || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                          );
                when others then
                    pc_log.log_batch_job_result('run_process_dep_all_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace
                    );
            end;
        end loop;

    exception
        when others then
            pc_log.log_batch_job_result('run_process_dep_all_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_process_dep_all_result_job;

    procedure run_export_en_request_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.request_transaction_export(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_export_EN_request_job', null, l_file_name
                                                                               || ' '
                                                                               || 'successfully generated and sent to metavante', null
                                                                               , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_export_EN_request_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_export_EN_request_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_export_en_request_job;

    procedure run_export_ec_request_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.request_account_export(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_export_EC_request_job', null, l_file_name
                                                                               || ' '
                                                                               || 'successfully generated and sent to metavante', null
                                                                               , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_export_EC_request_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_export_EC_request_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_export_ec_request_job;

    procedure run_process_ec_export_job is

        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_status        varchar2(30);
        l_return_code   number;
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('EXPORT', 'EC');
        if l_file_name is null then
            raise no_file_found;
        else
            pc_debit_card.update_card_balance(l_status, l_error_message, l_file_name);
            commit;
            pc_log.log_batch_job_result('run_process_EC_export_job', null, l_file_name || ' Processing Completed Successfully', null,
            l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_process_EC_export_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_process_EC_export_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_process_ec_export_job;

    procedure run_export_pending_auth_request_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.request_pending_auth_export(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_export_pending_auth_request_job', null, l_file_name
                                                                                         || ' '
                                                                                         || 'successfully generated and sent to metavante'
                                                                                         , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_export_pending_auth_request_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_export_pending_auth_request_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace)
            ;
    end run_export_pending_auth_request_job;

    procedure run_hra_dep_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.hra_dep_creation(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_hra_dep_creation_job', null, l_file_name
                                                                              || ' '
                                                                              || 'successfully generated and sent to metavante', null
                                                                              , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_hra_dep_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_hra_dep_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_hra_dep_creation_job;

    procedure run_fsa_dep_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.fsa_dep_creation(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_fsa_dep_creation_job', null, l_file_name
                                                                              || ' '
                                                                              || 'successfully generated and sent to metavante', null
                                                                              , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_fsa_dep_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_fsa_dep_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_fsa_dep_creation_job;

    procedure run_dep_card_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.dep_card_creation(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_dep_card_creation_job', null, l_file_name
                                                                               || ' '
                                                                               || 'successfully generated and sent to metavante', null
                                                                               , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_card_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_dep_card_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_card_creation_job;


-- #Custom dependent card creation for HSA
    procedure run_custom_dep_card_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.custom_dep_card_creation(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_dep_card_creation_job', null, l_file_name
                                                                               || ' '
                                                                               || 'successfully generated and sent to metavante', null
                                                                               , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_custom_dep_card_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_custom_dep_card_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_custom_dep_card_creation_job;

    procedure run_dep_terminate_job is
        l_file_name   varchar2(250);
        l_return_code integer;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.dep_terminate(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_dep_terminate_job', null, l_file_name
                                                                           || ' '
                                                                           || 'successfully generated and sent to metavante', null, l_start_date
                                                                           ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_terminate_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_dep_terminate_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_terminate_job;

    procedure run_dep_lost_stolen_job is
        l_file_name    varchar2(250);
        l_if_file_name varchar2(250);
        l_return_code  integer;
        l_start_date   date;
    begin
        l_start_date := sysdate;
        pc_debit_card.dep_lost_stolen(null, l_file_name, l_if_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_dep_lost_stolen_job', null, l_file_name
                                                                             || ' '
                                                                             || 'successfully generated and sent to metavante', null,
                                                                             l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_lost_stolen_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_dep_lost_stolen_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_lost_stolen_job;

    procedure run_dep_demographic_update_job is
        l_file_name   varchar2(250);
        l_return_code integer;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.dep_demographic_update(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_dep_demographic_update_job', null, l_file_name
                                                                                    || ' '
                                                                                    || 'successfully generated and sent to metavante'
                                                                                    , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_demographic_update_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_dep_demographic_update_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_demographic_update_job;

    procedure run_dep_unsuspend_job is
        l_file_name   varchar2(250);
        l_return_code integer;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.dep_unsuspend(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_dep_unsuspend_job', null, l_file_name
                                                                           || ' '
                                                                           || 'successfully generated and sent to metavante', null, l_start_date
                                                                           ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_unsuspend_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_dep_unsuspend_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_unsuspend_job;

    procedure run_dep_lost_stolen_ccard_job is
        l_file_name    varchar2(250);
        l_if_file_name varchar2(250);
        l_start_date   date;
        l_return_code  number;
    begin
        l_start_date := sysdate;
        pc_debit_card.dep_lost_stolen_reorder(null, l_file_name, l_if_file_name);
        commit;
        if l_if_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_if_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_dep_lost_stolen_ccard_job', null, l_if_file_name
                                                                                   || ' '
                                                                                   || 'successfully generated and sent to metavante',
                                                                                   null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_lost_stolen_ccard_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_dep_lost_stolen_ccard_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_lost_stolen_ccard_job;

    procedure run_dep_suspend_job is
        l_file_name   varchar2(250);
        l_start_date  date;
        l_return_code integer;
    begin
        l_start_date := sysdate;
        pc_debit_card.dep_suspend(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_dep_suspend_job', null, l_file_name
                                                                         || ' '
                                                                         || 'successfully generated and sent to metavante', null, l_start_date
                                                                         ,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_suspend_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_dep_suspend_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_suspend_job;

    procedure run_dep_card_creation_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('DEP_CARD_CREATION', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_dep_card_creation_result_job', null, l_file_name || ' Processing Completed Successfully'
            , null, l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_card_creation_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_dep_card_creation_result_job', -20002, 'File '
                                                                                    || l_file_name
                                                                                    || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                    );
        when others then
            pc_log.log_batch_job_result('run_dep_card_creation_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_card_creation_result_job;

    procedure run_dep_terminate_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('DEP_TERMINATE', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_dep_terminate_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_terminate_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_dep_terminate_result_job', -20002, 'File '
                                                                                || l_file_name
                                                                                || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                );
        when others then
            pc_log.log_batch_job_result('run_dep_terminate_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_terminate_result_job;

    procedure run_dep_lost_stolen_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('DEP_LOST', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_dep_lost_stolen_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_lost_stolen_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_dep_lost_stolen_result_job', -20002, 'File '
                                                                                  || l_file_name
                                                                                  || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                  );
        when others then
            pc_log.log_batch_job_result('run_dep_lost_stolen_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_lost_stolen_result_job;

    procedure run_dep_unsuspend_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('DEP_UNSUSPEND', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_dep_unsuspend_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_unsuspend_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_dep_unsuspend_result_job', -20002, 'File '
                                                                                || l_file_name
                                                                                || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                );
        when others then
            pc_log.log_batch_job_result('run_dep_unsuspend_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_unsuspend_result_job;

    procedure run_dep_lost_stolen_cresult_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('DEP_LOST_IF', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_dep_lost_stolen_cresult_job', null, l_file_name || ' Processing Completed Successfully',
            null, l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_lost_stolen_cresult_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_dep_lost_stolen_cresult_job', -20002, 'File '
                                                                                   || l_file_name
                                                                                   || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                   );
        when others then
            pc_log.log_batch_job_result('run_dep_lost_stolen_cresult_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_lost_stolen_cresult_job;

    procedure run_dep_suspend_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('DEP_SUSPEND', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_dep_suspend_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_dep_suspend_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_dep_suspend_result_job', -20002, 'File '
                                                                              || l_file_name
                                                                              || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                              );
        when others then
            pc_log.log_batch_job_result('run_dep_suspend_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_dep_suspend_result_job;

    procedure run_fsa_ee_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.fsa_ee_creation(null, l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_fsa_ee_creation_job', null, l_file_name
                                                                             || ' '
                                                                             || 'successfully generated and sent to metavante', null,
                                                                             l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_fsa_ee_creation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_fsa_ee_creation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_fsa_ee_creation_job;

    procedure run_fsa_ee_creation_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('FSA_EE_CREATION', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_fsa_ee_creation_result_job', null, l_file_name || ' Processing Completed Successfully', null
            , l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_fsa_ee_creation_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_fsa_ee_creation_result_job', -20002, 'File '
                                                                                  || l_file_name
                                                                                  || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                  );
        when others then
            pc_log.log_batch_job_result('run_fsa_ee_creation_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_fsa_ee_creation_result_job;

    procedure run_process_pending_auth_export_job is

        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_status        varchar2(30);
        l_return_code   number;
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('EN', 'EXPORT');
        if l_file_name is null then
            raise no_file_found;
        else
            pc_debit_card.post_pending_authorizations(l_status, l_error_message, l_file_name);
            commit;
            pc_log.log_batch_job_result('run_process_pending_auth_export_job', null, l_file_name || ' Processing Completed Successfully'
            , null, l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_process_pending_auth_export_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_process_pending_auth_export_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace)
            ;
    end run_process_pending_auth_export_job;

    procedure run_interest_deposit_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_debit_card.interest_rates(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_meta_source_path, g_metavante_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_interest_deposit_job', null, l_file_name
                                                                              || ' '
                                                                              || 'successfully generated and sent to metavante', null
                                                                              , l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_interest_deposit_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_interest_deposit_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_interest_deposit_job;

    procedure run_process_en_export_job is

        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_status        varchar2(30);
        l_return_code   number;
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('EN', 'EXPORT');
        if l_file_name is null then
            raise no_file_found;
        else
            pc_debit_card.process_settlements(l_status, l_error_message, l_file_name);
            commit;
            pc_log.log_batch_job_result('run_process_EN_export_job', null, l_file_name || ' Processing Completed Successfully', null,
            l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_process_EN_export_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_process_EN_export_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_process_en_export_job;

    procedure run_interest_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('INTEREST', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_interest_result_job', null, l_file_name || ' Processing Completed Successfully', null, l_start_date
            ,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_interest_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_interest_result_job', -20002, 'File '
                                                                           || l_file_name
                                                                           || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                           );
        when others then
            pc_log.log_batch_job_result('run_interest_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_interest_result_job;

    procedure run_lost_stolen_create_result_job is
        l_file_name     varchar2(250);
        l_error_message varchar2(4000);
        l_start_date    date;
    begin
        l_start_date := sysdate;
        l_file_name := pc_debit_card.get_file_name('LOST_IF', 'RESULT');
        if l_file_name is null then
            raise no_file_found;
        elsif
            l_file_name is not null
            and file_exists(l_file_name, 'DEBIT_CARD_DIR') = 'FALSE'
        then
            raise file_does_not_exist;
        else
            pc_debit_card.process_result(l_file_name, l_error_message);
            commit;
            pc_log.log_batch_job_result('run_lost_stolen_create_result_job', null, l_file_name || ' Processing Completed Successfully'
            , null, l_start_date,
                                        sysdate);

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_lost_stolen_create_result_job', -20001, 'File Not Found in METAVANTE table', dbms_utility.format_error_backtrace
            );
        when file_does_not_exist then
            pc_log.log_batch_job_result('run_lost_stolen_create_result_job', -20002, 'File '
                                                                                     || l_file_name
                                                                                     || ' does not exist in METAVANTE folder', dbms_utility.format_error_backtrace
                                                                                     );
        when others then
            pc_log.log_batch_job_result('run_lost_stolen_create_result_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_lost_stolen_create_result_job;

    procedure run_send_er_check_job is
        l_return_code number;
        l_file_name   varchar2(250);
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_check_process.send_er_check_cnb(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_admin_source_path, g_adminisource_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_send_er_check_job', null, l_file_name || 'successfully generated and sent to adminisource'
                , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_send_er_check_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_send_er_check_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_send_er_check_job;

    procedure run_send_hrafsa_er_check_job is
        l_return_code number;
        l_file_name   varchar2(250);
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_check_process.send_fsa_hra_er_check_cnb(l_file_name);
        commit;
-- pc_log.log_error('PC_scheduled_jobs.run_send_hrafsa_er_check_job','l_file_name '||l_file_name);

        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_admin_source_path, g_adminisource_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_send_hrafsa_er_check_job', null, l_file_name || 'successfully generated and sent to adminisource'
                , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_send_hrafsa_er_check_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_send_hrafsa_er_check_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_send_hrafsa_er_check_job;

    procedure run_send_check_job is
        l_return_code number;
        l_file_name   varchar2(250);
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_check_process.send_check_cnb(null, 'READY', l_file_name);
        commit;
-- pc_log.log_error('PC_scheduled_jobs.run_send_check_job','l_file_name '||l_file_name);

        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_admin_source_path, g_adminisource_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_send_check_job', null, l_file_name || 'successfully generated and sent to adminisource'
                , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_send_check_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_send_check_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_send_check_job;

    procedure run_send_edi_check_job is
        l_return_code number;
        l_file_name   varchar2(250);
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_check_process.send_edi_check_cnb(null, l_file_name);
        commit;
-- pc_log.log_error('PC_scheduled_jobs.run_send_edi_check_job','l_file_name '||l_file_name);

        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_admin_source_path, g_adminisource_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_send_edi_check_job', null, l_file_name || 'successfully generated and sent to adminisource'
                , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_send_edi_check_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_send_edi_check_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_send_edi_check_job;

    procedure run_send_hsa_check_job is
        l_return_code number;
        l_file_name   varchar2(250);
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_check_process.send_hsa_check_cnb(null, 'READY', l_file_name);
        commit;
-- pc_log.log_error('PC_scheduled_jobs.run_send_hsa_check_job','l_file_name '||l_file_name);

        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_admin_source_path, g_adminisource_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_send_hsa_check_job', null, l_file_name || 'successfully generated and sent to adminisource'
                , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_send_hsa_check_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_send_hsa_check_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_send_hsa_check_job;

    procedure run_send_cobra_check_job is
        l_return_code number;
        l_file_name   varchar2(250);
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_check_process.send_cobra_check_cnb(l_file_name);
        commit;
-- pc_log.log_error('PC_scheduled_jobs.run_send_cobra_check_job','l_file_name '||l_file_name);

        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_admin_source_path, g_adminisource_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_send_cobra_check_job', null, l_file_name || 'successfully generated and sent to adminisource'
                , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_send_cobra_check_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_send_cobra_check_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_send_cobra_check_job;

    procedure run_send_manual_check_job is
        l_return_code number;
        l_file_name   varchar2(250);
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_check_process.send_manual_check_cnb(l_file_name);
        commit;
-- pc_log.log_error('PC_scheduled_jobs.run_send_manual_check_job','l_file_name '||l_file_name);

        if l_file_name is null then
            raise no_file_found;
        else
            for i in (
                select
                    column_value
                from
                    table ( cast(str2tbl(l_file_name) as varchar2_4000_tbl) )
            ) loop
                pc_log.log_error('PC_scheduled_jobs.run_send_manual_check_job', 'i.column_value ' || i.column_value);
                if file_exists(i.column_value, 'CHECKS_DIR') = 'TRUE' then
                    l_return_code := transfer_files_to_edi(i.column_value, g_admin_source_path, g_adminisource_folder);
                    pc_log.log_error('PC_scheduled_jobs.run_send_manual_check_job', 'l_return_code  ' || l_return_code);
                    if l_return_code = 0 then
                        pc_log.log_batch_job_result('run_send_manual_check_job', null, i.column_value || 'successfully generated and sent to adminisource'
                        , null, l_start_date,
                                                    sysdate);
                    end if;

                end if;

            end loop;
        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_send_manual_check_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_send_manual_check_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_send_manual_check_job;

    procedure run_receive_check_job is

        l_return_code number;
        l_start_date  date;
        v_count       number;
        v_x_file_name varchar2(100);
        v_file_name   varchar2(100);
        cursor c1 is
        select
            'Receipt_' || file_name x_file_name,
            file_name
        from
            external_files
        where
                nvl(result_flag, 'N') = 'N'
            and file_length(file_name, 'CHECKS_DIR') > 0
            and file_action = 'CHECK'
        order by
            file_id asc;

    begin
        open c1;
        loop
            fetch c1 into
                v_x_file_name,
                v_file_name;
            exit when c1%notfound;
            l_start_date := sysdate;
            begin
                pc_check_process.process_check_result(v_file_name);
                commit;
                pc_log.log_batch_job_result('run_receive_check_job', null, v_file_name || ' Processing Completed Successfully', null,
                l_start_date,
                                            sysdate);

            exception
                when others then
                    pc_log.log_batch_job_result('run_receive_check_job', sqlcode, v_file_name
                                                                                  || ' - '
                                                                                  || sqlerrm, dbms_utility.format_error_backtrace);
            end;

        end loop;

        if c1%rowcount = 0 then
            raise no_file_found;
        end if;
        close c1;
    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_receive_check_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_receive_check_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_receive_check_job;

    procedure run_saas_check_file_generation_job is

        l_return_code   number;
        x_error_message varchar2(100);
        x_return_status varchar2(100);
        l_file_name     varchar2(250);
        l_start_date    date;
    begin
        l_start_date := sysdate;

/*clearpay.pc_check_process.send_check
                  ( p_user_id       => 0
                   ,p_customer_id   => '201'
                   ,x_file_name     => l_file_name
                   ,x_error_message => x_error_message
                   ,x_return_status => x_return_status
                   );
                   COMMIT;
                   */
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_admin_source_path, g_adminisource_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_saas_check_file_generation_job', null, l_file_name
                                                                                        || ' '
                                                                                        || 'successfully generated and sent to Adminisource'
                                                                                        , null, l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_saas_check_file_generation_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_saas_check_file_generation_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_saas_check_file_generation_job;

    procedure run_saas_check_result_process_job is
        l_return_code number;
        l_file_name   varchar2(250);
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_check_process.process_check_result(l_file_name);
        commit;
        if l_file_name is null then
            raise no_file_found;
        else
            l_return_code := transfer_files_to_edi(l_file_name, g_admin_source_path, g_adminisource_folder);
            if l_return_code = 0 then
                pc_log.log_batch_job_result('run_saas_check_result_process_job', null, l_file_name || 'Successfully Completed', null,
                l_start_date,
                                            sysdate);

            end if;

        end if;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_saas_check_result_process_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace
            );
        when others then
            pc_log.log_batch_job_result('run_saas_check_result_process_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_saas_check_result_process_job;

    procedure run_nacha_file_creation_job is
        l_file_name   varchar2(250);
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        for k in (
            select distinct
                ( decode(n.account_type, 'FEE_PAY', null, n.account_type) ) account_type
            from
                nacha_data n
        ) loop
            pc_log.log_error('Begining of PC_scheduled_jobs.run_nacha_file_creation_job', 'k.ACCOUNT_TYPE := ' || k.account_type);
            begin
                pc_auto_process.generate_nacha_file_employee(k.account_type, l_file_name);  -- Added by Swamy for Ticket#11701
                pc_log.log_error('Employee Ending of PC_scheduled_jobs.run_nacha_file_creation_job **1 ', 'l_file_name := ' || l_file_name
                );
                commit;
                if l_file_name is null then
                    raise no_file_found;
                else
                    l_return_code := transfer_files_to_edi(l_file_name, g_nacha_source_path, g_nacha_folder);
                    pc_log.log_error('Employee after transfering to .19  ', 'l_return_code := ' || l_return_code);
                    if l_return_code = 0 then
                        pc_log.log_batch_job_result('Employee run_nacha_file_creation_job', null, l_file_name
                                                                                                  || ' '
                                                                                                  || 'successfully generated and sent to Nacha'
                                                                                                  , null, l_start_date,
                                                    sysdate);
                    end if;

                end if;

            exception
                when no_file_found then
                    pc_log.log_batch_job_result('Employee run_nacha_file_creation_job', -20001, 'File Not Found for ' || k.account_type
                    , dbms_utility.format_error_backtrace);
                when others then
                    pc_log.log_batch_job_result('Employee run_nacha_file_creation_job for account ' || k.account_type, sqlcode, sqlerrm
                    , dbms_utility.format_error_backtrace);
            end;

            begin
                pc_auto_process.generate_nacha_file_employer(k.account_type, l_file_name);  -- Added by Swamy for Ticket#11701
                pc_log.log_error('EMPLOYER **2 ', 'l_file_name := ' || l_file_name);
                commit;
                if l_file_name is null then
                    raise no_file_found;
                else
                    l_return_code := transfer_files_to_edi(l_file_name, g_nacha_source_path, g_nacha_folder);
                    pc_log.log_error(' EMPLOYER transfering to .19  ', 'l_return_code := ' || l_return_code);
                    if l_return_code = 0 then
                        pc_log.log_batch_job_result(' EMPLOYER run_nacha_file_creation_job', null, l_file_name
                                                                                                   || ' '
                                                                                                   || 'successfully generated and sent to Nacha'
                                                                                                   , null, l_start_date,
                                                    sysdate);
                    end if;

                end if;

            exception
                when no_file_found then
                    pc_log.log_batch_job_result('EMPLOYER run_nacha_file_creation_job', -20001, 'File Not Found for account ' || k.account_type
                    , dbms_utility.format_error_backtrace);
                when others then
                    pc_log.log_batch_job_result('EMPLOYER run_nacha_file_creation_job for account ' || k.account_type, sqlcode, sqlerrm
                    , dbms_utility.format_error_backtrace);
            end;

            begin
                pc_auto_process.generate_nacha_file_fee(k.account_type, l_file_name);  -- Added by Swamy for Ticket#11701
                pc_log.log_error('FEE  **3 ', 'l_file_name := ' || l_file_name);
                commit;
                if l_file_name is null then
                    raise no_file_found;
                else
                    l_return_code := transfer_files_to_edi(l_file_name, g_nacha_source_path, g_nacha_folder);
                    pc_log.log_error('FEE transfering to .19  ', 'l_return_code := ' || l_return_code);
                    if l_return_code = 0 then
                        pc_log.log_batch_job_result('FEE run_nacha_file_creation_job', null, l_file_name
                                                                                             || ' '
                                                                                             || 'successfully generated and sent to Nacha'
                                                                                             , null, l_start_date,
                                                    sysdate);
                    end if;

                end if;

            exception
                when no_file_found then
                    pc_log.log_batch_job_result('FEE run_nacha_file_creation_job', -20001, 'File Not Found for account ' || k.account_type
                    , dbms_utility.format_error_backtrace);
                when others then
                    pc_log.log_batch_job_result('FEE run_nacha_file_creation_job for account ' || k.account_type, sqlcode, sqlerrm, dbms_utility.format_error_backtrace
                    );
            end;

        end loop;

    end run_nacha_file_creation_job;

    procedure run_receive_nacha_job is

        l_return_code number;
        l_start_date  date;
        v_count       number;
        v_x_file_name varchar2(100);
        v_file_name   varchar2(100);
    begin
        l_start_date := sysdate;
        begin
            pc_auto_process.process_nacha_file;
            commit;
            pc_log.log_batch_job_result('run_receive_nacha_job', null, null || ' Processing Completed Successfully', null, l_start_date
            ,
                                        sysdate);

        exception
            when others then
                pc_log.log_batch_job_result('run_receive_nacha_job', sqlcode, null
                                                                              || ' - '
                                                                              || sqlerrm, dbms_utility.format_error_backtrace);
        end;

    exception
        when no_file_found then
            pc_log.log_batch_job_result('run_receive_nacha_job', -20001, 'File Not Found', dbms_utility.format_error_backtrace);
        when others then
            pc_log.log_batch_job_result('run_receive_nacha_job', sqlcode, sqlerrm, dbms_utility.format_error_backtrace);
    end run_receive_nacha_job;

    procedure run_ee_qb_balances_report_job is
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_notification2.ee_qb_balances_report;
        pc_log.log_batch_job_result('run_ee_qb_balances_report_job', null, null || ' Employee QB Balance Report generated Successfully'
        , null, l_start_date,
                                    sysdate);

    exception
        when others then
            pc_log.log_batch_job_result('run_ee_qb_balances_report_job', sqlcode, null
                                                                                  || ' - '
                                                                                  || sqlerrm, dbms_utility.format_error_backtrace);
    end run_ee_qb_balances_report_job;

    procedure run_er_qb_balances_report_job is
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_notification2.er_qb_balances_report;
        pc_log.log_batch_job_result('run_er_qb_balances_report_job', null, null || ' The Emloyer QB Balance Report generated Successfully'
        , null, l_start_date,
                                    sysdate);

    exception
        when others then
            pc_log.log_batch_job_result('run_ee_qb_balances_report_job', sqlcode, null
                                                                                  || ' - '
                                                                                  || sqlerrm, dbms_utility.format_error_backtrace);
    end run_er_qb_balances_report_job;

    procedure daily_feedback_report is
        l_return_code number;
        l_start_date  date;
    begin
        l_start_date := sysdate;
        pc_notification2.daily_feedback_report;
        pc_log.log_batch_job_result('Daily_feedback_report', null, null || ' The Daily feeback Report generated Successfully', null, l_start_date
        ,
                                    sysdate);

    exception
        when others then
            pc_log.log_batch_job_result('Daily_feedback_report', sqlcode, null
                                                                          || ' - '
                                                                          || sqlerrm, dbms_utility.format_error_backtrace);
    end daily_feedback_report;

end pc_scheduled_jobs;
/


-- sqlcl_snapshot {"hash":"f15f0a6e9c11eb52e48f805eac176b57a33f7e35","type":"PACKAGE_BODY","name":"PC_SCHEDULED_JOBS","schemaName":"SAMQA","sxml":""}