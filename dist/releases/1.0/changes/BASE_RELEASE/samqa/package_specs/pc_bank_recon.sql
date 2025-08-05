-- liquibase formatted sql
-- changeset SAMQA:1754374134103 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\pc_bank_recon.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/pc_bank_recon.sql:null:9a0637cf60b9eba289874ca7414faf252301711d:create

create or replace package samqa.pc_bank_recon as
    type check_rec is record (
            check_number      varchar2(30),
            bank_check_number varchar2(30),
            status            varchar2(30),
            claim_id          varchar2(30),
            acc_num           varchar2(30),
            note              varchar2(3200)
    );
    type check_t is
        table of check_rec;
    function get_check_details (
        p_check_list in varchar2
    ) return check_t
        pipelined
        deterministic;

end pc_bank_recon;
/

