-- liquibase formatted sql
-- changeset SAMQA:1754374145715 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\reprocess_crmc_error_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/reprocess_crmc_error_claims.sql:null:631358f41a7ff4d3eb9bef555802b9b1d34309fd:create

create or replace procedure samqa.reprocess_crmc_error_claims is
begin
    for x in (
        select
            claim_interface_id,
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
                and b.orig_sys_vendor_ref = substr(a.member_id, 1, 10)
                || '1'
                   and b.pers_id = d.pers_id
            and error_message like 'Cannot get account number of member id%'
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
            and error_message like 'Cannot get account number of member id%'
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
            and error_message like 'Cannot get account number of member id%'
    ) loop
        pc_claim.process_uploaded_claims(0, x.batch_number);
    end loop;

end;
/

