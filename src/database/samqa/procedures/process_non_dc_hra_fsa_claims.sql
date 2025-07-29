create or replace procedure samqa.process_non_dc_hra_fsa_claims as
/** Processing cheyenne claims for participants that have both
HRA/FSA claims but never used their debit card **/
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
            and d.claim_amount > 0
            and not exists (
                select
                    *
                from
                    payment
                where
                        payment.acc_id = a.acc_id
                    and payment.pay_date >= d.service_start_date
                    and payment.reason_code = 13
            )
        order by
            a.acc_num
    ) loop
        update claimn
        set
            claim_status = 'APPROVED_FOR_CHEQUE',
            approved_amount = x.claim_amount,
            reviewed_date = sysdate,
            approved_date = sysdate,
            reviewed_by = 0,
            released_date = sysdate,
            released_by = 0,
            note = note
                   || ' Auto released on '
                   || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss')
        where
            claim_id = x.claim_id;

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"1273278137ad8bec9a4be6b8da6a6e902f77d5ab","type":"PROCEDURE","name":"PROCESS_NON_DC_HRA_FSA_CLAIMS","schemaName":"SAMQA","sxml":""}