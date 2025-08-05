-- liquibase formatted sql
-- changeset SAMQA:1754374145036 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\process_dup_dc_hra_fsa_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/process_dup_dc_hra_fsa_claims.sql:null:fa173687ce2e6e9041fa2efa8524303d492f8e0f:create

create or replace procedure samqa.process_dup_dc_hra_fsa_claims as
/** Processing cheyenne claims for participants that have both
HRA/FSA claims but  used their debit card and found duplicates
so marking them as pending forever**/
begin
    for x in (
        select distinct
            d.claim_amount,
            a.acc_num,
            d.service_start_date,
            a.claim_id
        from
            claim_interface a,
            claimn          d
        where
                a.pers_id = d.pers_id
            and a.claim_id = d.claim_id
            and d.claim_status = 'AWAITING_APPROVAL'
            and a.interface_status = 'INTERFACED'
            and exists (
                select
                    *
                from
                    payment
                where
                        payment.acc_id = a.acc_id
                    and payment.pay_date >= d.service_start_date
                    and payment.reason_code = 13
                    and d.claim_amount = payment.amount
            )
        order by
            a.acc_num
    ) loop
        update claimn
        set
            claim_status = 'PENDING'
        where
            claim_id = x.claim_id;

    end loop;
end;
/

