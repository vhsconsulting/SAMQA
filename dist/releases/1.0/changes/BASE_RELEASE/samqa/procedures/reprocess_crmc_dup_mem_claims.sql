-- liquibase formatted sql
-- changeset SAMQA:1754374145691 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\reprocess_crmc_dup_mem_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/reprocess_crmc_dup_mem_claims.sql:null:2b5e8be4008b374a33aa0947810798b6c45ca25d:create

create or replace procedure samqa.reprocess_crmc_dup_mem_claims (
    p_member_id in varchar2
) is
begin
    for x in (
        select
            claim_interface_id,
            batch_number,
            member_id,
            b.entrp_id,
            b.pers_id,
            d.acc_id,
            d.acc_num
        from
            claim_interface a,
            person          b,
            account         d
        where
                interface_status = 'ERROR'
            and b.pers_id = d.pers_id
            and b.entrp_id = pc_entrp.get_entrp_id(a.er_acc_num)
            and b.orig_sys_vendor_ref = substr(member_id,
                                               1,
                                               length(member_id) - 2)
                                        || '01'
      --AND   A.CREATION_DATE > '01-FEB-2013'
            and a.er_acc_num = 'GFSA006937'
            and error_code like 'MULTIPLE_ACCOUNTS'
            and a.member_id = p_member_id
    ) loop
        update claim_interface
        set
            entrp_id = x.entrp_id,
            pers_id = x.pers_id,
            acc_id = x.acc_id,
            acc_num = x.acc_num,
            interface_status = 'NOT_INTERFACED'
        where
            claim_interface_id = x.claim_interface_id;

        pc_claim_interface.initialize_edi_claims(x.batch_number);
    end loop;

    for x in (
        select
            claim_interface_id,
            acc_num,
            batch_number
        from
            claim_interface a
        where
                interface_status = 'NOT_INTERFACED'
            and error_code like 'MULTIPLE_ACCOUNTS'
    ) loop
        pc_claim.import_uploaded_claims(0, x.batch_number);
    end loop;

    for x in (
        select
            claim_interface_id,
            acc_num,
            batch_number
        from
            claim_interface a
        where
                interface_status = 'INTERFACED'
            and error_code like 'MULTIPLE_ACCOUNTS'
    ) loop
        pc_claim.process_uploaded_claims(0, x.batch_number);
    end loop;

end reprocess_crmc_dup_mem_claims;
/

