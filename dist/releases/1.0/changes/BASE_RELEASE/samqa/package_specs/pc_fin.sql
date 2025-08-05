-- liquibase formatted sql
-- changeset SAMQA:1754374137845 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_fin.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_fin.sql:null:a90ffae77f2d7c2e56ff85b29c5a4dadc1eabf0d:create

create or replace package samqa.pc_fin is

/*
 Most financial logic for KOA
 09.04.2006 mal + Get_balance
 01.07.2005 mal + Pc_Fin.allow_deduct_year
 14.06.2005 mal Move from PC_PERSON Allows and Receipts=payed
*/
-- DECLARE PACKAGE variables ----
    pv_allow_deduct_year number; -- lesser of the annual deductible OR $2,650 FOR an individual OR $5,250 FOR a family.
    pv_flag number; -- mark for triggers
    pv_debug number; -- mark for debug
----- END DECLARE ------------

  -- define interest rate
    function interate (
        balance_in in number,
        dat_in     in date default trunc(sysdate, 'mm'),
        vid_in     in varchar2
    ) return number;

    procedure calc_balance (
        acc_in in number default null,
        dat_in in date default trunc(sysdate, 'mm')
    );
-- insert Interest in DB (INCOME.fee_code = 8)
    procedure acc_interest (
        acc_in in number,
        dat_in in date,
        amt_in in number,
        am_out out number,
        ch_out out number
    );

    procedure recalc_balance (
        dat_from in date default sysdate - 31,
        dat_to   in date default sysdate,
        acc_in   in number default null  -- NULL means all accounts
        ,
        priz_in  in number default 0  -- 1 = calc %
    );

    procedure take_setup (
        acc_in in number,
        dat_in in date,
        fee_in in number
    );

    procedure take_month (
        acc_in in number,
        dat_in in date,
        fee_in in number
    );

    procedure take_fees (
        acc_in in number default null,
        dat_in in date default trunc(sysdate, 'mm')
    );
 -- for acc_id_in  return amount income in  year_in
    function receipts (
        acc_id_in in account.acc_id%type,
        year_in   in date default sysdate
    ) return number;

-- for person_id calculation allowed in year_in

    procedure allows (
        pers_id_in in person.pers_id%type,
        year_in    in date default sysdate,
        deduc_out  out number  -- main
        ,
        add_out    out number   -- add older 55
    );

    function allow_fee (
        acc_id_in in account.acc_id%type,
        year_in   in date default sysdate
    ) return number;

    procedure card_open_fee (
        pers_id_in in person.pers_id%type
    );

    procedure card_claim_fee (
        acc_id_in   in payment.acc_id%type,
        claim_id_in in payment.claimn_id%type,
        source_in   in varchar2 default 'MBI'
    );

--  year deductible, but limited params ALLOW.
    function allow_deduct_year (
        acc_id_in in account.acc_id%type,
        year_in   in date default sysdate
    ) return number;

    procedure need_calc_balance (
        acc_in in number
    );

    procedure insert_fee_for_bank (
        p_acc_id     in number,
        p_fee_reason in number,
        p_amount     number default 0,
        p_claim_id   number default null
    );

-- check, and recalc balance, if need from date last changed
    procedure dbgt (
        str in varchar2,
        pp  number default null
    );

-- debug
    function get_balance (
        acc_in in number,
        dat_in in date default sysdate
    ) return number;

    function get_balancint (
        acc_in in number,
        dat_in in date default sysdate
    ) return number;

    procedure bill_pay_fee (
        p_acc_id in number default null
    );

    procedure update_debit_card_settlements;

    procedure process_eb_settlement (
        acc_id_in     in number,
        dat_in        in varchar2,
        amount_in     in number,
        claimn_id     in number,
        trans_code_in in number,
        source_in     in varchar2 default 'MBI'
    );

    procedure close_payment (
        p_claim_id       in number,
        p_pers_id        in number,
        p_claim_code     in varchar2,
        p_provider_name  in varchar2,
        p_start_date     in date,
        p_pers_patient   in varchar2,
        p_service_status in number,
        p_tax_code       in varchar2,
        p_claim_amount   in number,
        p_fee_date       in date,
        p_disb_amount    in number,
        p_claim_type     in number,
        p_check_number   in number,
        p_payment_note   in number
    );

    procedure activate_account;

    procedure suspend_account;

    procedure process_suspended_account;

    procedure close_pending_account (
        p_acc_id in number default null
    );

    function get_bill_pay_fee (
        p_acc_id in number
    ) return number;

    procedure annual_investment_fee_payment;

    procedure annual_fee_payment;

    procedure lost_stolen_payment (
        p_acc_id    in number,
        p_plan_code in number,
        p_note      in varchar2
    );

    procedure delete_fee (
        acc_id_in          in payment.acc_id%type,
        change_num_in      in payment.change_num%type,
        reason_code_in     in number,
        p_orig_reason_code in number
    );

    procedure create_outside_investment (
        p_investment_id  in number,
        p_invest_date    in varchar2,
        p_ending_balance in number,
        p_note           in varchar2,
        p_user_name      in varchar2,
        x_error_message  out varchar2
    );
  /** When a cheque is posted back dated, interest has to be recalculated again and an adjustment
     had to be created **/

    function recalculate_interest (
        dat_from in date default sysdate - 31,
        dat_to   in date default sysdate,
        acc_in   in number default null  -- NULL means all accounts
        ,
        priz_in  in number default 0  -- 1 = calc %
    ) return number;

    procedure payment_fee_insert (
        acc_id_in          in payment.acc_id%type,
        change_num_in      in payment.change_num%type,
        reason_code_in     in number,
        p_orig_reason_code in number
    );

    function contribution_limit (
        pers_id_in in number,
        year_in    in date default sysdate
    ) return number;

    function contribution_ytd (
        acc_id_in         in number,
        account_type_in   in varchar2,
        plan_type_in      in varchar2,
        p_plan_start_date in date default null,
        p_plan_end_date   in date default null
    ) return number;

    function disbursement_ytd (
        acc_id_in         in number,
        account_type_in   in varchar2,
        plan_type_in      in varchar2,
        reason_code_in    in number,
        p_plan_start_date in date default null,
        p_plan_end_date   in date default null
    ) return number;

    function claim_filed_ytd (
        acc_id_in         in number,
        account_type_in   in varchar2,
        plan_type_in      in varchar2,
        p_plan_start_date in date default null,
        p_plan_end_date   in date default null
    ) return number;

    function deductible_ytd (
        acc_id_in         in number,
        p_plan_start_date in date default null,
        p_plan_end_date   in date default null,
        p_pers_id         in number default null
    ) return number;

    procedure create_employer_deposit (
        p_list_bill          in number,
        p_entrp_id           in number,
        p_check_amount       in number,
        p_check_date         in date,
        p_posted_balance     in number,
        p_fee_bucket_balance in number,
        p_remaining_balance  in number,
        p_user_id            in number,
        p_plan_type          in varchar2,
        p_note               in varchar2,
        p_reason_code        in number default 4,
        p_check_number       in varchar2 default null
    );

    procedure create_receipt (
        p_acc_id            in number,
        p_fee_date          in date,
        p_entrp_id          in number,
        p_er_amount         in number default 0,
        p_ee_amount         in number default 0,
        p_er_fee            in number default 0,
        p_ee_fee            in number default 0,
        p_pay_code          in number,
        p_plan_type         in varchar2,
        p_debit_card_posted in varchar2,
        p_list_bill         in number,
        p_fee_reason        in number,
        p_note              in varchar2,
        p_check_amount      in number,
        p_user_id           in number,
        p_check_number      in varchar2 default null
    );

    procedure create_prefunded_receipt (
        p_batch_number in number,
        p_user_id      in number,
        p_acc_num      in varchar2 default null
    );

    function is_rolled_over (
        p_acc_id   in number,
        p_fee_date in date
    ) return varchar2;

    function get_rollover_date (
        p_acc_id   in number,
        p_fee_date in date
    ) return date;

    function get_monthly_contribution (
        p_amount    in number,
        p_frequency in varchar2
    ) return number;

    type balance_row_t is record (
            pre_tax         number,
            post_tax        number,
            monthly_contrib number,
            frequency       varchar2(100)
    );
    type balance_t is
        table of balance_row_t;
    function get_balance_details (
        p_acc_id_in       in number,
        p_plan_type       in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_entrp_id        in number
    ) return balance_t
        pipelined
        deterministic;

    procedure take_annual (
        acc_in in number,
        dat_in in date,
        fee_in in number
    );

-- Added by Swamy on 27/01/2023
-- Check if Employee is included in invoice. Deduct the fees amount only if the employee is included in the invoice.
-- Do not deduct the fees amount if employee is not included in the invoice.
    function chk_employee_included_in_invoice (
        p_entrp_id in number,
        p_pers_id  in number,
        p_dat_in   in date
    ) return varchar2;

end pc_fin;
/

