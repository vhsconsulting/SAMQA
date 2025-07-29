create or replace package samqa.pc_eob_utility is
    type eob_rec_t is record (
            eob_id                 varchar2(255),
            eob_ref_no             varchar2(255),
            patient_name           varchar2(255),
            provider_name          varchar2(255),
            service_amount         varchar2(255),
            eob_source             varchar2(255),
            description            varchar2(255),
            eob_status             varchar2(255),
            received_date          varchar2(30),
            processed_date         varchar2(30),
            charged_amt            number,
            eob_balance            number,
            service_date_from      date,
            claim_id               number,
            disbursement_date      varchar2(30),
            service                varchar2(100),
            state_tax              varchar2(30),
            patient_responsibility varchar2(30)
    );
    type eob_t is
        table of eob_rec_t;
    type eob_detail_rec_t is record (
            line_no                number,
            service_provider       varchar2(255),
            service_date_from      varchar2(30),
            service_date_to        varchar2(30),
            service_desc           varchar2(3200),
            description            varchar2(3200),
            disc_amt               number,
            charged_amt            number,
            discount_amt           number,
            excluded_amt           number,
            covered_amt            number,
            coinsurance_amt        number,
            co_pay_amt             number,
            deductible_amt         number,
            cob_paid_amt           number,
            paid_amt               number,
            cost_of_service_amt    number,
            received_date          varchar2(30),
            processed_date         varchar2(30),
            state_tax              varchar2(30),
            patient_responsibility varchar2(30),
            eob_detail_id          number,
            eob_id                 varchar2(30)
    );
    type eob_detail_t is
        table of eob_detail_rec_t;
    function get_eob_info (
        p_user_id in number,
        p_acc_id  in number,
        p_ssn     in varchar2
    ) return eob_t
        pipelined
        deterministic;

    function get_eob_detail_info (
        p_eob_id in varchar2
    ) return eob_detail_t
        pipelined
        deterministic;

    function get_eob_info (
        p_acc_id in number
    ) return eob_t
        pipelined
        deterministic;

    function get_disburse_info (
        p_acc_id   in number,
        p_claim_id in number
    ) return eob_t
        pipelined
        deterministic;

    function get_eob_exists (
        p_acc_id in number
    ) return varchar2;

    function get_allow_eob (
        p_pers_id in number
    ) return varchar2;

    type eobrefno_tbl is
        table of varchar2(3200) index by binary_integer;
    function array_fill (
        p_array       in eobrefno_tbl,
        p_array_count in number
    ) return eobrefno_tbl;

    procedure associate_eob (
        p_claimid in number,
        p_accid   in number,
                       --   P_USERID  IN NUMBER,
        p_eobref  in eobrefno_tbl
    );

    procedure reassociate_eob (
        p_claimid in number
    );

    procedure update_eob_status;

    procedure update_eob_userid;

end pc_eob_utility;
/


-- sqlcl_snapshot {"hash":"30eedd07e389e15313df458717aa584ad39bf1c3","type":"PACKAGE_SPEC","name":"PC_EOB_UTILITY","schemaName":"SAMQA","sxml":""}