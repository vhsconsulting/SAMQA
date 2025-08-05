-- liquibase formatted sql
-- changeset SAMQA:1754374142229 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_web_utility_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_web_utility_pkg.sql:null:4f979525a1a9dc1c14adc46dc5206dba1107405c:create

create or replace package samqa.pc_web_utility_pkg is
    type user_record_row_t is record (
            username      varchar2(1000),
            ssn           varchar2(20),
            user_id       varchar2(20),
            error_message varchar2(1000)
    );
    type user_record_t is
        table of user_record_row_t;
    type balance_record_row_t is record (
            ssn                 varchar2(20),
            account_type        varchar2(20),
            acct_num            varchar2(100),
            acct_id             number(10),
            balance             number(15, 5),
            error_message       varchar2(1000),
            show_account_online varchar2(2)    -- Added by Swamy Prod issue  14-mar-23
    );
    type acc_info_row_t is record (
            acc_num        varchar2(30),
            acc_id         number,
            pers_id        number,
            plan_name      varchar2(1000),
            effective_date varchar2(30),
            acct_balance   number(10, 3),
            error_message  varchar2(100)
    );
    type acc_details_row_t is record (
            name            varchar2(100),
            acc_num         varchar2(10),
            acct_type       varchar2(1000),
            effective_date  varchar2(10),
            acct_balance    number,
            plan_type       varchar2(100),
            plan_desc       varchar2(2000),
            annual_election number,
            address         varchar2(300),
            city            varchar2(300),
            state           varchar2(300),
            zip             varchar2(300),
            acc_id          number,
            error_message   varchar2(100)
    );
    type acc_details_t is
        table of acc_details_row_t;
    type bank_record_row_t is record (
            bank_acc_id      varchar2(10),
            acc_id           varchar2(10),
            acc_num          varchar2(10),
            display_name     varchar2(100),
            bank_acct_type   varchar2(10),
            account_type     varchar2(100),
            bank_acct_num    varchar2(20),
            bank_routing_num varchar2(10),
            error_message    varchar2(1000)
    );
    type fee_desc_row_t is record (
            fee_code varchar2(10),
            fee_name varchar2(100)
    );
    type user_lock_record_t is record (
            user_name      varchar2(1000),
            confirmed_flag varchar2(10),
            failed_att     number(10),
            locked_time    number(10),
            emp_reg_type   varchar2(10),
            user_type      varchar2(10)
    );
    type user_lock_record is
        table of user_lock_record_t;
    type reason_code_record_t is record (
            lookup_code varchar2(10),
            lookup_name varchar2(100),
            description varchar2(1000),
            meaning     varchar2(1000)
    );
    type reason_code_t is
        table of reason_code_record_t;
    type disbur_contrib_record_t is record (
            fee_date  varchar2(20),
            fee_name  varchar2(100),
            amount    number,
            plan_type varchar2(100)
    );
    type schd_txn_record_t is record (
            txn_date varchar2(20),
            txn_id   number,
            status   varchar2(100),
            amount   number(15, 5)
    );
    type ret_acct_type_t is record (
        account_type varchar2(10)
    );
    type ret_contrb_amt_t is record (
            pers_id           number,
            effective_date    varchar2(20),
            plan_type         varchar2(100),
            contrb_limit      number,
            current_yr_contrb number,
            total_disb_amount number
    );
    type ret_acct_det is record (
            acc_id    number,
            error_msg varchar2(1000)
    );
    type claim_record_t is record (
            claim_id             number,
            claim_date           varchar2(100),
            claim_amount         number,
            provider_name        varchar2(2000),
            service_type         varchar2(100),
            service_type_meaning varchar2(100),
            pers_id              number,
            acc_id               number,
            acc_num              varchar2(100),
            claim_status         varchar2(100),
            offset_amount        number,
            remaining_offset     number,
            reason_name          varchar2(100),
            reason_code          number
    );
    type employee_record_t is record (
            rownum_1           number,
            employee_name      varchar2(255),
            first_name         varchar2(255),
            last_name          varchar2(255),
            acc_num            varchar2(255),
            start_date         varchar2(30),
            acc_status         varchar2(30),
            pers_id            number,
            acc_id             number,
            er_acc_id          number,
            hsa_effective_date varchar2(30),
            enroll_complete    varchar2(30)
    );
    type card_suspend_t is record (
        status varchar2(2000)
    );
    type debit_claim_t is record (
            claim_status           varchar2(100),
            claim_paid             number(15, 5),
            paid_date              varchar2(20),
            claim_pending          number(15, 5),
            unsubstantiated_amount number(15, 5),
            reimbursement_method   varchar(1000)
    );
    type get_plan_yr_t is record (
            plan_yr        varchar2(100),
            plan_yr_format varchar2(100),
            plan_type      varchar2(100)
    );
    type get_contrib_type_t is record (
            fee_code fee_names.fee_code%type,
            fee_name fee_names.fee_name%type
    );

  -- Added by Joshi for PPP.
    type get_payroll_freq_t is record (
            lookup_code varchar2(30),
            meaning     varchar2(255)
    );
    type ret_payroll_freq is
        table of get_payroll_freq_t;
    type ret_get_plan_yr is
        table of get_plan_yr_t;
    type ret_acct_t is
        table of ret_acct_det;
    type ret_contrb_amt is
        table of ret_contrb_amt_t;
    type ret_acct_type is
        table of ret_acct_type_t;
    type schd_txn_record is
        table of schd_txn_record_t;
    type disbur_contrib_record is
        table of disbur_contrib_record_t;
    type fee_desc_t is
        table of fee_desc_row_t;
    type bank_record_t is
        table of bank_record_row_t;
    type acc_info_record is
        table of acc_info_row_t;
    type balance_record_t is
        table of balance_record_row_t;
    type claim_t is
        table of claim_record_t;
    type employee_t is
        table of employee_record_t;
    type ret_debit_claim_t is
        table of debit_claim_t;
    type ret_card_suspend_t is
        table of card_suspend_t;
    type ret_contrib_type_t is
        table of get_contrib_type_t;
    function get_acc_info (
        p_acc_num in varchar2
    ) return acc_info_record
        pipelined
        deterministic;
/** Added this for Mobile APP relese : Vanitha: 03/22/2016*/

    function get_acc_info_by_tax_id (
        p_ssn in varchar2
    ) return acc_info_record
        pipelined
        deterministic;

    function get_balances (
        p_ssn          in varchar2,
        p_account_type in varchar2
    ) return balance_record_t
        pipelined
        deterministic;

    function validate_users (
        p_user_name in varchar2 default null,
        p_passwd    in varchar2 default null
    ) return user_record_t
        pipelined
        deterministic;

    function get_bank_details (
        p_acc_num   in varchar2,
        p_tran_type in varchar2
    ) return bank_record_t
        pipelined
        deterministic;

    function get_fee_details return fee_desc_t
        pipelined
        deterministic;

    function get_acct_details (
        p_acc_num in varchar2
    ) return acc_details_t
        pipelined
        deterministic;

    function get_reason_details return reason_code_t
        pipelined
        deterministic;

    function get_disbur_contrib_details (
        p_tran_type in varchar2,
        p_acc_id    in number,
        p_acct_type in varchar2
    ) return disbur_contrib_record
        pipelined
        deterministic;

    function get_schd_txn (
        p_tran_type in varchar2,
        p_acc_id    in number
    ) return schd_txn_record
        pipelined
        deterministic;

    function get_acct_type (
        p_user_name in varchar2
    ) return ret_acct_type
        pipelined
        deterministic;

    function get_contrb_amt (
        p_acc_num in varchar2
    ) return ret_contrb_amt
        pipelined
        deterministic;

    function get_acct_num_det (
        p_acc_num in varchar2
    ) return ret_acct_t
        pipelined
        deterministic;

    function get_dc_unsub_claims (
        p_acc_num     in varchar2,
        p_reason_code in number
    ) return claim_t
        pipelined
        deterministic;

    function get_dc_unsub_claim_det (
        p_claim_id in number
    ) return claim_t
        pipelined
        deterministic;

    function get_hsa_employees (
        p_er_accnum    in varchar2,
        p_search_by    in varchar2,
        p_search_value in varchar2,
        p_sort_by      in varchar2,
        p_sort_order   in varchar2,
        p_start_row    in varchar2,
        p_end_row      in varchar2
    )  -- Added by Swamy for Ticket#12013 12022024
     return employee_t
        pipelined
        deterministic;

    function get_active_hsa_employees (
        p_er_accnum    in varchar2,
        p_search_by    in varchar2,
        p_search_value in varchar2,
        p_sort_by      in varchar2,
        p_sort_order   in varchar2
    ) return employee_t
        pipelined
        deterministic;

    function has_active_plan (
        p_acc_num in varchar2
    ) return number;

    function display_debit_card_claim (
        p_claim_id in varchar2
    ) return ret_debit_claim_t
        pipelined
        deterministic;

    function check_card_suspend (
        p_acc_num in varchar2
    ) return ret_card_suspend_t
        pipelined
        deterministic;

    procedure update_reason (
        p_claim_id in varchar2,
        p_user_id  in number
    );

    function get_hra_profile (
        p_acc_num in varchar2
    ) return acc_details_t
        pipelined
        deterministic;

    function get_plan_yr (
        p_acc_id    in number,
        p_plan_type in varchar2
    ) return ret_get_plan_yr
        pipelined
        deterministic;

    function get_sterling_address return varchar2;

    function get_sterling_address1 return varchar2;

    function get_sterling_city return varchar2;

    function get_sterling_state return varchar2;

    function get_sterling_zip return varchar2;

    function get_payroll_schedule (
        p_acc_id            in number,
        p_plan_type         in varchar2,
        p_scheduler_id      in number,
        p_freq_code         in varchar2,
        p_start_dt          date,
        p_end_dt            date,
        p_no_of_pay_periods number
    ) -- Added by Jaggi #11365
     return date_table;

    function get_sterling_cs_info return varchar2;
 --SLN
    function get_contrib_type (
        p_acc_id in varchar2
    ) return ret_contrib_type_t
        pipelined
        deterministic;
 --
-- by Joshi for payroll project.
    function get_payroll_frequency return ret_payroll_freq
        pipelined
        deterministic;

 -- Added By Jaggi
    type mob_pending_disburs_record_t is record (
            claim_id           number,
            claim_amount       number(15, 2),
            service_type       varchar2(30),
            service_start_date date,
            service_end_date   date,
            bank_acct_id       number,
            vendor_id          number,
            patient_name       varchar2(30),
            edit_type          varchar2(30),
            service_name       varchar2(30),
            claim_status       varchar2(30),
            creation_date      date,
            pay_info           varchar2(100)
    );
    type mob_pending_disburs_record is
        table of mob_pending_disburs_record_t;

 -- Added by Swamy for Ticket#12013 12022024
    type fsahrahsa_employee_record_t is record (
            rownum_1           number,
            upload_date        varchar2(30),
            file_name          varchar2(255),
            file_upload_result varchar2(255),
            no_of_employees    varchar2(255),
            file_upload_id     varchar2(300),
            rn                 varchar2(300)
    );
    type fsahrahsa_employee_t is
        table of fsahrahsa_employee_record_t;
    function get_mob_pending_disbursments (
        p_acc_id in number
    ) return mob_pending_disburs_record
        pipelined
        deterministic;

-- added by Jaggi #11365
    function get_payroll_frequency_fsa_hra return ret_payroll_freq
        pipelined
        deterministic;

-- Added by Swamy for Ticket#12013 12022024
    function get_bulk_enroll_renewal (
        p_entrp_id     in number,
        p_process_type in varchar2,
        p_start_row    in varchar2,
        p_end_row      in varchar2
    ) return fsahrahsa_employee_t
        pipelined
        deterministic;

end pc_web_utility_pkg;
/

