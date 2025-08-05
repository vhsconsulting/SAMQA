-- liquibase formatted sql
-- changeset SAMQA:1754374135046 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_cobra_disbursement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_cobra_disbursement.sql:null:5f7b366f1de9580095f01d39ff498357762287fa:create

create or replace package samqa.pc_cobra_disbursement is
    type qb_statement_rec is record (
            billing_period   varchar2(100),
            division_name    varchar2(1000),
            carrier          varchar2(1000),
            benefit_plan     varchar2(1000),
            qb_name          varchar2(1000),
            premium_amount   varchar2(1000),
            premium_due_date varchar2(30),
            deposit_date     varchar2(30),
            client_id        number,
            qb_member_id     number,
            entrp_id         number,
            acc_num          varchar2(100)
    );
    type cobra_address_rec is record (
            from_name      varchar2(100),
            from_address1  varchar2(1000),
            from_address2  varchar2(1000),
            from_address3  varchar2(1000),
            from_address4  varchar2(1000),
            remit_name     varchar2(1000),
            remit_attn     varchar2(1000),
            remit_address1 varchar2(1000),
            remit_address2 varchar2(1000),
            check_date     varchar2(30),
            check_note     varchar2(100),
            client_id      number,
            entrp_id       number,
            acc_num        varchar2(100)
    );
    type qb_statement_tbl is
        table of qb_statement_rec;
    type cobra_address_tbl is
        table of cobra_address_rec;
    procedure populate_disbursement_staging (
        p_start_date         in date,
        p_end_date           in date,
        p_last_end_date      in date,
        p_report_date        in date,
        p_postmark_date_from in date,
        p_postmark_date_to   in date,
        p_client_id          in number
    );

    procedure populate_disbursement (
        p_start_date in date,
        p_end_date   in date,
        p_client_id  in number
    );

    function get_disbursement_report (
        p_cobra_disbursement_id in number
    ) return qb_statement_tbl
        pipelined;

    function get_disbursement_header (
        p_cobra_disbursement_id in number
    ) return cobra_address_tbl
        pipelined;

    procedure run_cobra_disbursement (
        p_client_id     in number,
        p_end_date      in date,
        p_last_end_date in date
    );

    function get_cobra_ach_claim_detail (
        p_trans_from_date in date,
        p_trans_to_date   in date
    ) return pc_claim.ach_claim_t
        pipelined
        deterministic;

    procedure process_cobra_disbursement (
        p_entrp_id       in number,
        p_reason_code    in number,
        p_claim_amount   in number,
        p_emp_payment_id in number,
        p_vendor_id      in number,
        p_bank_acct_id   in number,
        p_note           in varchar2,
        p_user_id        in number,
        x_return_status  out varchar2,
        x_error_message  out varchar2
    );

  -- Added by Swamy for Cobrapoint 02/11/2022
    procedure post_premium_invoice (
        p_transaction_id in number,
        p_user_id        in number
    );

    procedure process_cobra_disbursement_auto;

    procedure auto_release_cobra_payment_by_check;

end;
/

