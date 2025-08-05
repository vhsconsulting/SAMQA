-- liquibase formatted sql
-- changeset SAMQA:1754374135012 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_claim_web_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_claim_web_pkg.sql:null:c48039bc485f061396c57bfd06dee2add8f39a6b:create

create or replace package samqa.pc_claim_web_pkg is
    type claim_summary_rec is record (
            service_type         varchar2(255),
            service_type_meaning varchar2(255),
            no_of_claims         number,
            total_claim          number,
            approved_amount      number,
            denied_amount        number,
            approved_date        varchar2(30),
            account_type         varchar2(30)
    );
    type claim_summary_t is
        table of claim_summary_rec;
    function get_er_claim_summary (
        p_entrp_id in number
    ) return claim_summary_t
        pipelined
        deterministic;

end pc_claim_web_pkg;
/

