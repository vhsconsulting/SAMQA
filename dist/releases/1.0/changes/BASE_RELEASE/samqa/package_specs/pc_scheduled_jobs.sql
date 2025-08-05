-- liquibase formatted sql
-- changeset SAMQA:1754374140741 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_scheduled_jobs.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_scheduled_jobs.sql:null:670902397a58bb918a52f979ece4caf5119c3fa5:create

create or replace package samqa.pc_scheduled_jobs as
    no_file_found exception;
    file_does_not_exist exception;
    procedure create_program_for_proc (
        p_program_name   in varchar2,
        p_procedure_name in varchar2
    );

    procedure create_job_for_proc (
        p_program_name  in varchar2,
        p_schedule_hour in number,
        p_schedule_min  in number
    );


  --l_batch_number NUMBER;

    procedure create_schedulers (
        p_job_name varchar2 default null
    );

    procedure drop_schedulers (
        p_job_name varchar2 default null
    );

   -- card creation
    procedure run_hra_fsa_card_creation_job;

    procedure run_hra_fsa_ee_card_creation_job;

    procedure run_card_creation_job;

    procedure run_custom_card_creation_job;

    procedure run_card_request_history_job;

   -- demographic creation
    procedure run_hra_er_creation_job;

    procedure run_er_plan_update_job;

    procedure run_hra_er_creation_result_job;

    procedure run_hra_ee_creation_job;

    procedure run_hra_ee_creation_result_job;

   -- terminate
    procedure run_terminate_job;

    procedure run_hra_fsa_terminate_job;

    procedure run_lost_stolen_job;

    procedure run_lost_stolen_create_card_job;

   -- #all export
    procedure run_export_em_request_job;

    procedure run_process_em_export_job;

    procedure run_demographic_update_job;

   -- # export files
    procedure run_unsuspend_job;

    procedure run_suspend_job;

   -- # process all the payment related information
    procedure run_deposit_payment_job;

    procedure run_payment_job;

    procedure run_hra_annual_election_job;

    procedure run_hra_deposits_job;

    procedure run_claim_job;

   -- #process result files
    procedure run_acc_num_change_result_job;

    procedure run_lost_stolen_result_job;

    procedure run_card_creation_result_job;

    procedure run_address_update_result_job;

    procedure run_terminate_result_job;

    procedure run_unsuspend_result_job;

    procedure run_deposit_result_job;

    procedure run_payment_result_job;

    procedure run_suspend_result_job;

    procedure run_process_all_result_job;

    procedure run_process_dep_all_result_job;

   -- export request
    procedure run_export_en_request_job;

    procedure run_export_ec_request_job;

    procedure run_process_ec_export_job;

    procedure run_export_pending_auth_request_job;

   -- # process all dependant related updates to metavante
    procedure run_hra_dep_creation_job;

    procedure run_fsa_dep_creation_job;

    procedure run_dep_card_creation_job;

   -- #Custom dependent card creation for HSA
    procedure run_custom_dep_card_creation_job;

    procedure run_dep_terminate_job;

    procedure run_dep_lost_stolen_job;

    procedure run_dep_demographic_update_job;

    procedure run_dep_unsuspend_job;

    procedure run_dep_lost_stolen_ccard_job;

    procedure run_dep_suspend_job;

    procedure run_dep_card_creation_result_job;

    procedure run_dep_terminate_result_job;

    procedure run_dep_lost_stolen_result_job;

    procedure run_dep_unsuspend_result_job;

    procedure run_dep_lost_stolen_cresult_job;

    procedure run_dep_suspend_result_job;

   -- # Missing (59-65)
    procedure run_fsa_ee_creation_job;

    procedure run_fsa_ee_creation_result_job;

    procedure run_process_pending_auth_export_job;

    procedure run_interest_deposit_job;

    procedure run_process_en_export_job;

    procedure run_interest_result_job;

    procedure run_lost_stolen_create_result_job;

   -- #Move adminisource files from php to shell script and move to ftp server
    procedure run_send_er_check_job;

    procedure run_send_hrafsa_er_check_job;

    procedure run_send_check_job;

    procedure run_send_edi_check_job;

    procedure run_send_hsa_check_job;

   -- PROCEDURE run_saas_check_file_generation_job;
    procedure run_send_cobra_check_job;

    procedure run_send_manual_check_job;

    procedure run_receive_check_job;

    procedure run_saas_check_result_process_job;

    procedure run_nacha_file_creation_job;

    procedure run_receive_nacha_job;
   
   -- COBRA EE/ER Balances report
    procedure run_ee_qb_balances_report_job;

    procedure run_er_qb_balances_report_job;

    procedure daily_feedback_report;

end pc_scheduled_jobs;
/

