-- liquibase formatted sql
-- changeset SAMQA:1754374140705 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_schedule.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_schedule.sql:null:d4321b15f21b7f11ef20ae580851ad446e08b97e:create

create or replace package samqa.pc_schedule as

  /* TODO enter package declarations (types, exceptions, methods etc) here */
    type schedule_date_table is
        table of date index by binary_integer;
    g_schedule_date schedule_date_table;
    type number_tbl is
        table of varchar(20) index by binary_integer;
    type schedule_detail_rec is record (
            acc_id                  number,
            acc_num                 varchar2(20),
            first_name              varchar2(200),
            last_name               varchar2(200),
            er_amount               number,
            ee_amount               number,
            er_fee_amount           number,  -- Added by Joshi for 9382
            ee_fee_amount           number,
            scheduler_detail_id     number,
            employee_account_status varchar2(100)
    );
    type scheduler_rec is record (
            scheduler_id         number,
            plan_type            varchar2(30),
            plan_type_desc       varchar2(100),
            recurring_flag       varchar2(1),
            recurring_freq       varchar2(50),
            recurring_freq_desc  varchar2(100),
            payment_start_date   varchar2(20),
            payment_end_date     varchar2(20),
            plan_start_date      varchar2(20),
            plan_end_date        varchar2(20),
            next_process_date    varchar2(20),
            total_amount         number,
            note                 varchar2(2000),
            error_message        varchar2(250),
            reason_code          number,
            contribution_type    varchar2(250),
            bank_name            varchar2(255),
            bank_acct_num        varchar2(20),
            bank_acct_id         number,
            no_of_pay_period     varchar2(50),   -- added by Joshi for 9382..
            post_prev_pay_period varchar2(50)
    ); -- added by Joshi for 11600.) ; 

    type schedule_detail_t is
        table of schedule_detail_rec;
    type scheduler_t is
        table of scheduler_rec;
    procedure ins_scheduler (
        p_acc_id               number,
        p_name                 varchar2,
        p_payment_method       varchar2,
        p_payment_type         varchar2,
        p_reason_code          number,
        p_payment_start_date   date,
        p_payment_end_date     date,
        p_recurring_flag       varchar2,
        p_recurring_frequency  varchar2,
        p_amount               number,
        p_fee_amount           number,
        p_bank_acct_id         number,
        p_contributor          number,
        p_plan_type            varchar2,
        p_orig_system_source   varchar2,
        p_orig_system_ref      varchar2,
        p_pay_to_all           varchar2,
        p_pay_to_all_amount    number,
        p_source               varchar2 default 'SAM',
        p_pay_dates            pc_online_enrollment.varchar2_tbl,
        p_user_id              number,
        p_note                 varchar2,
        p_post_prev_pay_period in varchar2 default 'N', -- Added by Jaggi for 10365
        p_no_of_pay_period     in varchar2 default null,  -- Added by Jaggi for 10365
        x_scheduler_id         out number,
        x_return_status        out varchar2,
        x_error_message        out varchar2
    );

    procedure delete_scheduler (
        p_scheduler_id  in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure update_scheduler (
        p_scheduler_id        in number,
        p_payment_method      varchar2,
        p_payment_type        varchar2,
        p_reason_code         number,
        p_payment_start_date  date,
        p_payment_end_date    date,
        p_recurring_flag      varchar2,
        p_recurring_frequency varchar2,
        p_amount              number,
        p_fee_amount          number,
        p_bank_acct_id        number,
        p_plan_type           varchar2,
        p_pay_to_all          varchar2,
        p_pay_to_all_amount   number,
        p_note                varchar2,
        p_user_id             number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    procedure mass_ins_scheduler_details (
        p_scheduler_id        number,
        p_acc_id              number_tbl,
        p_er_amount           number_tbl,
        p_ee_amount           number_tbl,
        p_er_fee_amount       number_tbl,
        p_ee_fee_amount       number_tbl,
        p_user_id             number,
        x_scheduler_detail_id out number_tbl,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    procedure ins_scheduler_details (
        p_scheduler_id        number,
        p_acc_id              number,
        p_er_amount           number,
        p_ee_amount           number,
        p_er_fee_amount       number,
        p_ee_fee_amount       number,
        p_user_id             number,
        p_note                varchar2 default null,
        x_scheduler_detail_id out number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    procedure update_transit_parking_sch (
        p_scheduler_id        number,
        p_acc_id              number,
        p_er_amount           number,
        p_ee_amount           number,
        p_er_fee_amount       number,
        p_ee_fee_amount       number,
        p_user_id             number,
        p_note                varchar2 default null,
        p_scheduler_detail_id in number,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    );

    function get_schedule (
        p_acc_id  in number,
        freq_code in varchar2,
        start_dt  date,
        end_dt    date
    ) return schedule_date_table;
 --PROCEDURE insert_income(
    function get_holiday (
        p_acc_id     in number,
        p_trans_date in date
    ) return date;

    function get_schedule_count (
        p_acc_id       in number,
        p_scheduler_id in number,
        freq_code      in varchar2,
        start_dt       date,
        end_dt         date
    ) return number;

    function get_contributed_amt (
        p_acc_id    in number,
        p_plan_type in varchar2,
        start_dt    date,
        end_dt      date
    ) return number;

    procedure generate_calendar (
        p_schedule_id in number,
        p_frequency   in varchar2,
        p_start_date  in date,
        p_end_date    in date,
        p_user_id     in number
    );

    function get_divided_amount (
        p_amount    in number,
        p_frequency in varchar2
    ) return number;

    procedure process_schedule (
        p_schedule_id in number,
        p_acc_id      in number default null,
        p_user_id     in number
    );

    procedure import_scheduler_details (
        p_scheduler_id  in number,
        p_user_id       in number,
        p_batch_number  in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure export_scheduler_detail_file (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure upload_scheduler_details (
        p_file_name     in varchar2,
        p_scheduler_id  in number,
        p_batch_number  in number,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure reconcile_employer_deposit (
        p_list_bill in number
    );

    function get_scheduler_id (
        p_entrp_id        in number,
        p_acc_id          in number,
        p_plan_type       in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    ) return number;

    procedure inactivate_scheduler (
        p_acc_id         in number,
        p_effective_date in date
    );

    function get_ach_schedule (
        p_start_dt       in date,
        p_end_dt         in date,
        p_payment_method in varchar2
    ) return date;

    procedure process_ach_schedule (
        p_schedule_id in number,
        p_acc_id      in number default null,
        p_user_id     in number
    );

    procedure ins_payroll_transfer (
        p_entrp_id     in number,
        p_amount       in number,
        p_trans_date   in date,
        p_user_id      in number,
        p_plan_type    in varchar2,
        p_check_number in varchar2,
        p_reason_code  in number,
        x_list_bill    out number,
        p_note         in varchar2 default null
    );

    procedure ins_payroll_transfer_details (
        p_acc_id       in number,
        trans_date     in date,
        er_amt         in number,
        ee_amt         in number,
        user_id        in number,
        p_plan_type    in varchar2,
        p_check_number in varchar2,
        p_check_amount in number,
        p_reason_code  in number,
        p_list_bill    in number,
        p_entrp_id     in number,
        p_note         in varchar2 default null
    );

    procedure create_rollover (
        p_entrp_id        in number,
        p_ben_plan_id     in number,
        p_acc_id          in number,
        p_amount          in number,
        p_plan_type       in varchar2,
        p_er_name         in varchar2,
        p_user_id         in number,
        p_plan_start_date in date,
        p_plan_end_date   in date
    );

    procedure process_rollover (
        p_schedule_id in number,
        p_acc_id      in number default null,
        p_user_id     in number
    );

    function check_ach_scheduled (
        p_source           in varchar2,
        p_source_id        in number,
        p_acc_id           in number,
        p_transaction_date in date,
        p_amount           in number,
        p_transaction_type in varchar2,
        p_scheduler_id     in number
    ) return varchar2;

    procedure alter_file (
        p_file_name in varchar2
    );

    procedure transform_file (
        p_file_name in varchar2
    );

    procedure generate_pay_calendar (
        p_frequency  in varchar2,
        p_start_date in date,
        p_end_date   in date,
        p_entrp_id   in number,
        p_user_id    in number
    );

    procedure copy_pay_calendar (
        p_schedule_id in number
    );

    procedure insert_payroll_cont_invoice (
        p_acc_id              in number,
        p_payroll_date        in date,
        p_amount              in number,
        p_plan_type           in varchar2,
        p_entrp_id            in number,
        p_scheduler_id        in number,
        p_scheduler_detail_id in number,
        p_user_id             in number
    );

/** Runs on February 1st of every year to create generic payroll calendar ***/
    procedure create_generic_calendar;

-- Added by Joshi for Payroll contribution.
    procedure initialize_scheduler (
        p_batch_number  in number,
        p_scheduler_id  in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure validate_scheduler (
        p_batch_number  in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure process_online_scheduler (
        p_batch_number         in number,
        p_scheduler_id         in out number,
        p_plan_type            in varchar2,
        p_acc_id               in number,
        p_acc_num              in varchar2,
        p_contributor          in number,
        p_payment_start_date   in varchar2,
        p_payment_end_date     in varchar2,
        p_recurring_flag       in varchar2,
        p_recurring_frequency  in varchar2,
        p_pay_dates            in pc_online_enrollment.varchar2_tbl,
        p_memo                 in varchar2,
        p_user_id              in number,
        p_bank_acct_id         in number   -- Added by Joshi for 9382
        ,
        p_payment_method       in varchar2 -- Added by Joshi for 9382
        ,
        p_reason_code          in number   -- Added by Joshi for 9382
        ,
        p_post_prev_pay_period in varchar2 -- Added by Jaggi for 10365
        ,
        p_no_of_pay_period     in varchar2 -- Added by Jaggi for 10365
        ,
        x_error_message        out varchar2,
        x_return_status        out varchar2
    );

    procedure insert_online_schd_stg_det (
        p_batch_number  in number,
        p_scheduler_id  in out number,
        p_ee_acc_id     in pc_online_enrollment.varchar2_tbl,
        p_er_amount     in pc_online_enrollment.varchar2_tbl,
        p_ee_amount     in pc_online_enrollment.varchar2_tbl,
        p_er_fee_amount in pc_online_enrollment.varchar2_tbl -- Added by Joshi for 9382
        ,
        p_ee_fee_amount in pc_online_enrollment.varchar2_tbl -- Added by Joshi for 9382
        ,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure generate_calendar (
        p_schedule_id in number,
        p_paydates    pc_online_enrollment.varchar2_tbl,
        p_user_id     in number
    );

    procedure mass_insert_scheduler_details (
        p_batch_number  in number,
        p_scheduler_id  in out number,
        p_acc_id        in pc_online_enrollment.varchar2_tbl,
        p_er_amount     in pc_online_enrollment.varchar2_tbl,
        p_ee_amount     in pc_online_enrollment.varchar2_tbl,
        p_er_fee_amount in pc_online_enrollment.varchar2_tbl,
        p_ee_fee_amount in pc_online_enrollment.varchar2_tbl,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    );

    procedure process_online_scheduler_det (
        p_batch_number  in number,
        p_file_name     in varchar2,
        p_scheduler_id  in out number,
        p_ee_acc_id     in pc_online_enrollment.varchar2_tbl,
        p_er_amount     in pc_online_enrollment.varchar2_tbl,
        p_ee_amount     in pc_online_enrollment.varchar2_tbl,
        p_er_fee_amount in pc_online_enrollment.varchar2_tbl -- Added by Joshi for 9382
        ,
        p_ee_fee_amount in pc_online_enrollment.varchar2_tbl -- Added by Joshi for 9382
        ,
        p_user_id       in number,
        p_confirm_flag  in varchar2 default 'N',
        p_memo          in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );
 -- Added p_plan_start_date and  p_plan_end_date by Joshi for 12559 - FSA/HRA - Sugar Tickets Enhancem
    function get_employee_schedule (
        p_entrp_id           in number,
        p_scheduler_id       in number,
        p_plan_type          varchar2,
        p_show_term_employee varchar2 default 'N',
        p_plan_start_date    varchar2,
        p_plan_end_date      varchar2
    ) return schedule_detail_t
        pipelined
        deterministic;

    function get_schedule_detail (
        p_scheduler_id in number,
        p_rec_freq     varchar2
    ) return scheduler_t
        pipelined
        deterministic;

    function get_emp_scheduler_detail (
        p_scheduler_id in number,
        p_acc_id       number,
        p_rec_freq     varchar2
    ) return scheduler_t
        pipelined
        deterministic;

    procedure delete_scheduler_line (
        p_scheduler_id  in number,
        p_ee_acc_id     in number,
        p_batch_number  in number,
        p_user_id       in number,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure run_sameday_scheduler;
/*** Process EDI scheduler ***/
    procedure schedule_edi_payroll (
        pv_file_name in varchar2
    );

    procedure export_payroll_contri_file (
        pv_file_name in varchar2,
        p_user_id    in number
    );

    procedure insert_into_staging (
        p_batch_number in number,
        p_file_name    in varchar2 default null
    );

    procedure initialize_edi_scheduler (
        p_batch_number in number
    );

    procedure validate_edi_scheduler (
        p_batch_number in number
    );

    procedure process_edi_scheduler (
        p_batch_number in number
    );

-- Added by Joshi to fix the pay per amount prod issue(#8127).
    function get_frequency (
        p_frequency  in varchar2,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function copy_schedule_detail (
        p_scheduler_id in number,
        p_rec_freq     varchar2
    ) return scheduler_t
        pipelined
        deterministic; -- Added By Jaggi #9382
/*** End of EDI **/

-- Added by Joshi for #9968.(monthly frequency date change issue for HSA)
    function get_schedule_hsa (
        p_acc_id  in number,
        freq_code in varchar2,
        start_dt  date,
        end_dt    date
    ) return schedule_date_table;

-- Added by Jaggi #11365
    procedure upsert_scheduler_calender_stage (
        p_batch_number in number,
        p_paydates     in pc_online_enrollment.varchar2_tbl,
        p_user_id      number
    );

    procedure insert_pay_date (
        p_batch_number in number,
        p_pay_date     in varchar2
    );

    procedure delete_pay_date (
        p_batch_number in number,
        p_pay_date     in varchar2
    );

    type er_plan_detail_rec is record (
            plan_name varchar2(50),
            plan_type varchar2(30)
    );
    type er_plan_detail_t is
        table of er_plan_detail_rec;
    function get_employer_plan (
        p_acc_id          in number,
        p_plan_start_date in varchar2,
        p_plan_end_date   in varchar2
    ) return er_plan_detail_t
        pipelined
        deterministic;

end pc_schedule;
/

