-- liquibase formatted sql
-- changeset SAMQA:1754374133948 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_account_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_account_details.sql:null:a394b87c9fb0e96b640f8b70fcb4c3cab63ea1d6:create

create or replace package samqa.pc_account_details as
    type over_contribution_row_t is record (
            acc_num               varchar2(255),
            fedmax                number,
            balance               number,
            age                   number,
            acc_id                number,
            over_contributed_date varchar2(12),
            no_of_dep             number,
            email                 varchar2(255)
    );
    type over_contribution_table_t is
        table of over_contribution_row_t;
    type debit_transaction_row_t is record (
            acc_num                  varchar2(255),
            acc_id                   number,
            pers_id                  number,
            sam_balance              number,
            metavante_balance        number,
            difference               number,
            pre_auth                 number,
            receipt_not_posted       number,
            payment_not_posted       number,
            edisbursement_not_posted number,
            last_receipt_date        date,
            last_payment_date        date,
            status                   varchar2(30)
    );
    type debit_transaction_t is
        table of debit_transaction_row_t;
    function get_receipts_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number;

    function get_interest_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function get_fee_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function get_disb_fee_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function get_fee_paid_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function get_disbursement_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function get_current_year_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number;

    function get_nqdisb_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function get_qdisb_total (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date
    ) return number;

    function get_prior_year_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number;

    function get_contribution (
        p_acc_id in number,
        p_year   in number
    ) return number;

    function get_fees (
        p_acc_id in number,
        p_year   in number
    ) return number;

    function get_over_contributed_date (
        p_acc_id in number,
        p_year   in number,
        p_fedmax in number
    ) return date;

    function get_over_contribution (
        p_year in number
    ) return over_contribution_table_t
        pipelined
        deterministic;

    function get_ee_receipts_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number;

    function get_er_receipts_total (
        p_acc_id         in number,
        p_start_date     in date,
        p_end_date       in date,
        p_effective_date in date default null
    ) return number;

    function get_debit_bal_decp (
        p_record_type in varchar2
    ) return debit_transaction_t
        pipelined
        deterministic;

    function get_disbursement_total_by_plan (
        p_acc_id     in number,
        p_start_date in date,
        p_end_date   in date,
        p_plan_type  in varchar2
    ) return number;

end;
/

