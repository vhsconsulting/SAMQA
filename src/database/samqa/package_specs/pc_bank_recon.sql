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


-- sqlcl_snapshot {"hash":"9a0637cf60b9eba289874ca7414faf252301711d","type":"PACKAGE_SPEC","name":"PC_BANK_RECON","schemaName":"SAMQA","sxml":""}