create or replace package samqa.pc_eob_upload is
    type eligibility_rec is record (
            first_name varchar2(255),
            last_name  varchar2(255),
            birth_date varchar2(255),
            ssn        varchar2(255),
            member_id  varchar2(255)
    );
    type eligibility_tbl is
        table of eligibility_rec;
    procedure log_eob_error (
        p_label   in varchar2,
        p_message in varchar2
    );

    procedure send_alert (
        p_file_name in varchar2
    );

    procedure eob_header_upload (
        p_header_file in varchar2
    );

    type t_eob_header is record (
            eobid       eob_header.eob_id%type,
            description eob_header.description%type,
            service_amt number,
            amt_due     number
    );
    procedure eob_detail_upload (
        p_detail_file in varchar2
    );

    procedure eob_eligible_upload (
        p_eligible_file in varchar2,
        p_load          in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    type t_eligible_rec is record (
            t_seq_num   eob_eligible_staging.eligible_upload_id%type,
            t_pers_id   person.pers_id%type,
            t_member_id insure.insurance_member_id%type,
            t_ssn       person.ssn%type
    );
    type eob_header_rec is record (
            claim_number        varchar2(255),
            provider_payee_name varchar2(255),
            provider_tax_id     varchar2(100),
            member_id           varchar2(100),
            ssn                 varchar2(100),
            patient_first_name  varchar2(100),
            patient_last_name   varchar2(100)
    );
    type t_eob_amt_rec is record (
            eobid       varchar2(255),
            service_amt number,
            amount_due  number
    );
    procedure eob_claims_upload (
        p_claims_file   in varchar2,
        p_load          in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure generate_uha_eligibility_file;

    procedure process_eob_claims (
        x_error_message out varchar2,
        x_return_status out varchar2
    );

    procedure uha_eob_claims_upload (
        p_claims_file   in varchar2,
        p_load          in varchar2,
        x_error_message out varchar2,
        x_return_status out varchar2
    );

end pc_eob_upload;
/


-- sqlcl_snapshot {"hash":"abca9e42c76925a4515771f1fa0be69366fa887e","type":"PACKAGE_SPEC","name":"PC_EOB_UPLOAD","schemaName":"SAMQA","sxml":""}