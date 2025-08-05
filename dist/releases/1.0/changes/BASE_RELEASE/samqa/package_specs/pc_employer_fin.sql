-- liquibase formatted sql
-- changeset SAMQA:1754374137310 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_employer_fin.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_employer_fin.sql:null:58ece4dfafb3af1acf9c86e6a547de27f2450a53:create

create or replace package samqa.pc_employer_fin as
    type report_rcon_rec is record (
            transaction_type    varchar2(100),
            acc_num             varchar2(100),
            claim_invoice_id    varchar2(100),
            check_amount        number,
            plan_type           varchar2(100),
            balance             number,
            reason_code         number,
            note                varchar2(4000),
            transaction_date    varchar2(100),
            paid_date           varchar2(100),
            first_name          varchar2(255),
            last_name           varchar2(255),
            ord_no              number,
            er_balance          number,
            employer_payment_id number
    );
    type employer_balance_rec is record (
            acc_num             varchar2(100),
            er_balance          number,
            claim_reimbursed_by varchar2(100),
            css                 varchar2(100),
            product_type        varchar2(100),
            employer_name       varchar2(1000),
            funding_options     varchar2(100)
    );
    type report_rcon_t is
        table of report_rcon_rec;
    type employer_balance_t is
        table of employer_balance_rec;
    type pay_rec is record (
            entrp_id            number,
            amount              number,
            check_num           varchar2(255),
            reason_code         number,
            paid_date           date,
            service_type        varchar2(255),
            plan_start_date     date,
            plan_end_date       date,
            transaction_source  varchar2(3200),
            employer_payment_id number,
            creation_date       date
    );
    type pay_tab is
        table of pay_rec;
    function get_employer_balance (
        p_entrp_id  in number,
        p_end_date  in date,
        p_plan_type in varchar2
    ) return number;

    function get_er_interest (
        dat_from    in date default sysdate - 31,
        dat_to      in date default sysdate,
        entrp_in    in number default null  -- NULL means all accounts
        ,
        p_plan_type in varchar2
    ) return number;

    procedure calculate_interest (
        dat_from    in date default sysdate - 31,
        dat_to      in date default sysdate,
        entrp_id_in in number
    );

    function get_fee_balance (
        p_entrp_id in number
    ) return number;

    function sum_er_interest (
        p_entrp_id  in number,
        p_end_date  in date,
        p_plan_type in varchar2
    ) return number;

    procedure create_employer_payment (
        p_entrp_id in number,
        p_date     in date default null
    );

    procedure create_employer_payment_detail (
        p_entrp_id in number,
        p_date     in date default null
    );

    procedure update_er_payment_detail (
        p_entrp_id in number
    );

    procedure refresh_er_balance;

    procedure activate_pop_account (
        p_entrp_id in number
    );

    procedure process_bal_parellel (
        p_entrp_id_from in number,
        p_entrp_id_to   in number
    );

    function get_er_recon_report (
        p_entrp_id     in number,
        p_product_type in varchar2,
        p_end_date     in date
    ) return report_rcon_t
        pipelined
        deterministic;

    function get_er_balance_report (
        p_entrp_id     in number,
        p_product_type in varchar2,
        p_end_date     in date
    ) return report_rcon_t
        pipelined
        deterministic;

    function get_funding_er_balance return employer_balance_t
        pipelined
        deterministic;

    function get_er_recon_report1 (
        p_entrp_id     in number,
        p_product_type in varchar2,
        p_end_date     in date
    ) return report_rcon_t
        pipelined
        deterministic;

    function get_funding_er_balance_by_date (
        p_end_date in date
    ) return employer_balance_t
        pipelined
        deterministic;

end pc_employer_fin;
/

