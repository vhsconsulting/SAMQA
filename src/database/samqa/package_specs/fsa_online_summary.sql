create or replace package samqa.fsa_online_summary as
    function get_fsa_summary_sql (
        p_acc_id      in number,
        p_report_type in varchar2
    ) return varchar2;

    function get_fsa_detail_sql (
        p_acc_id          in number,
        p_plan_start_date in varchar2,
        p_plan_end_date   in varchar2,
        p_start_date      in varchar2,
        p_end_date        in varchar2,
        p_report_type     in varchar2
    ) return varchar2;

    function get_fsa_ee_summary_sql (
        p_acc_id      in number,
        p_report_type in varchar2
    ) return varchar2;

    function get_fsa_ee_detail_sql (
        p_acc_id     in number,
        p_plan_start in varchar2,
        p_plan_end   in varchar2,
        p_start_date in varchar2,
        p_end_date   in varchar2
    ) return varchar2;

    function get_hra_ee_detail_sql (
        p_acc_id     in number,
        p_plan_start in varchar2,
        p_plan_end   in varchar2,
        p_start_date in varchar2,
        p_end_date   in varchar2
    ) return varchar2;

-- Start addition by Swamy for SQL Injection
    type contrib_row is record (
            rownum1          varchar2(4000),
            transaction_id   varchar2(500) -- Replaced Number to VARCHAR2(500) by swamy for Ticket#8124
            ,
            acc_id           ach_transfer.acc_id%type,
            amount           ach_transfer.amount%type,
            fee_amount       ach_transfer.fee_amount%type,
            total_amount     ach_transfer.total_amount%type,
            bank_acct_id     ach_transfer.bank_acct_id%type,
            transaction_date varchar2(20),
            status_message   varchar2(20),
            reason_code      ach_transfer.reason_code%type,
            check_number     employer_deposits.check_number%type,
            list_bill        employer_deposits.list_bill%type,
            posted_amount    ach_transfer.amount%type,
            check_amount     employer_deposits.check_amount%type,
            check_date       varchar2(20),
            pay_type         employer_deposits.pay_code%type,
            payment_method   varchar2(200),
            refund_amount    employer_deposits.refund_amount%type,
            status           ach_transfer.status%type,
            scheduler_id     number -- Added by Joshi for 9382.
    );
    type contrib_tbl is
        table of contrib_row;
    function get_pending_contribution (
        p_acc_id in number
    ) return contrib_tbl
        pipelined
        deterministic;

--FUNCTION get_processed_contribution ( p_acc_id IN NUMBER)
    function get_processed_contribution (
        p_acc_id in number,
        p_year   varchar2
    ) -- Joshi 9382
     return contrib_tbl
        pipelined
        deterministic;

    function get_cancelled_contribution (
        p_acc_id in number
    ) return contrib_tbl
        pipelined
        deterministic;
-- End of addition by Swamy for SQL Injection

end fsa_online_summary;
/


-- sqlcl_snapshot {"hash":"6671b9261d2efa86af4645b9e25e9de9c01b7c6d","type":"PACKAGE_SPEC","name":"FSA_ONLINE_SUMMARY","schemaName":"SAMQA","sxml":""}