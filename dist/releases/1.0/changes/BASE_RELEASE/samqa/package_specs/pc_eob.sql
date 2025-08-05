-- liquibase formatted sql
-- changeset SAMQA:1754374137584 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_eob.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_eob.sql:null:9311a345499e1c4dbc9e440a69e4102c742bc02b:create

create or replace package samqa.pc_eob as
    type varchar2_tbl is
        table of varchar2(3200) index by binary_integer;
    procedure insert_eob_header (
        p_eob_id         in varchar2,
        p_claim_number   in varchar2,
        p_provider_id    in number,
        p_description    in varchar2,
        p_service_start  in varchar2,
        p_service_end    in varchar2,
        p_service_amount in number,
        p_amount_due     in number,
        p_modified       in varchar2,
        p_source         in varchar2,
        p_acc_id         in number,
        p_user_id        in number
    );

    procedure insert_eob_detail (
        p_eob_id         in varchar2,
        p_eob_detail_id  in pc_online_enrollment.varchar2_tbl,
        p_service_start  in pc_online_enrollment.varchar2_tbl,
        p_service_end    in pc_online_enrollment.varchar2_tbl,
        p_description    in pc_online_enrollment.varchar2_tbl,
        p_medical_code   in pc_online_enrollment.varchar2_tbl,
        p_amount_charged in pc_online_enrollment.varchar2_tbl,
        p_ins_amount     in pc_online_enrollment.varchar2_tbl,
        p_final_amount   in pc_online_enrollment.varchar2_tbl,
        p_source         in varchar2,
        p_modified       in pc_online_enrollment.varchar2_tbl,
        p_user_id        in number
    );

    procedure insert_vendor_from_eob (
        p_provider_id   in number,
        p_acc_id        in number,
        p_payee_type    in varchar2,
        p_payee_acc_num in varchar2,
        p_user_id       in number,
        x_vendor_id     out number
    );

    procedure update_claim_with_eob (
        p_eob_id   in varchar2,
        p_claim_id in number,
        p_user_id  in number
    );

    procedure send_file (
        x_file_name out varchar2
    );

    procedure process_hex_status (
        p_file_name     in varchar2,
        x_error_message out varchar2
    );

    procedure update_hex_status;

    function get_eob_number (
        p_claim_id in number
    ) return varchar2;

end pc_eob;
/

