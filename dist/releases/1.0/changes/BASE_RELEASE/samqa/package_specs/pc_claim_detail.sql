-- liquibase formatted sql
-- changeset SAMQA:1754374134987 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_claim_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_claim_detail.sql:null:19c10d9902b2a5e686a338bd2a78b33f929fac6e:create

create or replace package samqa.pc_claim_detail is
    type varchar2_tbl is
        table of varchar(3200) index by binary_integer;
    type number_tbl is
        table of number index by binary_integer;
    procedure insert_claim_detail (
        p_claim_id         in number,
        p_serice_provider  in pc_online_enrollment.varchar2_tbl,
        p_service_date     in pc_online_enrollment.varchar2_tbl,
        p_service_end_date in pc_online_enrollment.varchar2_tbl,
        p_service_name     in pc_online_enrollment.varchar2_tbl,
        p_service_price    in pc_online_enrollment.varchar2_tbl,
        p_patient_dep_name in pc_online_enrollment.varchar2_tbl,
        p_medical_code     in pc_online_enrollment.varchar2_tbl,
        p_service_code     in varchar2,
        p_note             in pc_online_enrollment.varchar2_tbl,
        p_provider_tax_id  in pc_online_enrollment.varchar2_tbl,
        p_eob_detail_id    in pc_online_enrollment.varchar2_tbl,
        p_created_by       in number,
        p_creation_date    in date,
        p_last_updated_by  in number,
        p_last_update_date in date,
        p_eob_linked       in pc_online_enrollment.varchar2_tbl --Added by Karthe K S on 23/02/2016 for the Pier ticket 2451 Health Expense Flag
        ,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    );

-- Added by Swamy for 11091
    type claim_detail_row_t is record (
            claim_id            number,
            service_start_date  varchar2(30),
            service_end_date    varchar2(30),
            claim_status        varchar2(30),
            note                varchar2(4000),
            service_name        varchar2(255),
            patient_dep_name    varchar2(3200),
            service_price       number,
            denied_amount       number,
            denied_reason       varchar2(255),
            tax_description     varchar2(255),
            claim_detail_status varchar2(30)
    );
    type claim_detail_t is
        table of claim_detail_row_t;

-- Added by Swamy for Ticket#11091
    function get_claim_detail (
        p_claim_id in number
    ) return claim_detail_t
        pipelined
        deterministic;

end pc_claim_detail;
/

