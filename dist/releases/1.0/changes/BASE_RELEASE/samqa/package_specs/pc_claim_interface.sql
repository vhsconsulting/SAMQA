-- liquibase formatted sql
-- changeset SAMQA:1754374135001 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_claim_interface.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_claim_interface.sql:null:96f39ed71771e9093ed632076a1d7a701ebf9d5d:create

create or replace package samqa.pc_claim_interface as

--PROCEDURE import_claims(p_user_id number, p_batch_number IN VARCHAR2);
    procedure export_claims_file (
        pv_file_name in varchar2,
        p_user_id    in number,
        p_claim_type in varchar2 default null
    );

    procedure process_claims (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    );

    procedure process_takeover_claims (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    );

    procedure ins_missing_account (
        p_claim_code       varchar2,
        p_note             varchar2,
        p_claim_error_flag varchar2
    );

    procedure import_into_interface (
        p_user_id      in number,
        p_batch_number in varchar2
    );

    procedure import_dep_into_interface (
        p_user_id      in number,
        p_batch_number in varchar2
    );

    procedure process_dep_claims (
        pv_file_name   in varchar2,
        p_user_id      in number,
        p_batch_number in varchar2
    );

    procedure initialize_edi_claims (
        p_batch_number in number
    );

    procedure reprocess_crmc_no_mem_claims;

end pc_claim_interface;
/

