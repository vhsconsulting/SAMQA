create or replace procedure samqa.process_debit_card_claims (
    p_file_name in varchar2
) as

    l_claim_id             number;
    l_sqlerrm              varchar2(3200);
    l_settlement_file_name varchar2(30) := 'MB_'
                                           || to_char(sysdate, 'YYYYMMDD')
                                           || '_EN.exp';
    l_file_name            varchar2(3200);
    l_utl_id               utl_file.file_type;
    l_create_error exception;
    l_exists               varchar2(1) := 'N';
    l_transaction_count    number := 0;
    l_count                number := 0;
    l_processed exception;
    x_error_message        varchar2(3200);
    x_error_status         varchar2(3200);
begin
    begin
        execute immediate 'ALTER TABLE CLAIM_UPLOAD_EXTERNAL LOCATION (CLAIM_DIR:'''
                          || p_file_name
                          || ''')';
    exception
        when others then
            rollback;
            l_sqlerrm := sqlerrm;
    end;

    for x in (
        select
            record_id,
            tpa_id,
            employee_id                     acc_num,
            plan_type,
            trans_date,
            sequence_number,
            claim_amount,
            check_number,
            check_date,
            reimbursement_method,
            partial_auth,
            partial_authorized,
            denied_amount,
            deductible_amount,
            merchant_name,
            transaction_amt,
            transaction_code,
            transaction_status,
            pos_flag,
            offset_amt,
            service_code,
            servic_desc,
            pay_provider,
            settlement_date,
            provider_id,
            transaction_process_code,
            manual_claim_number,
            pended_amount,
            b.acc_id,
            decode(pay_provider, 1, 11, 12) pay_reason,
            b.pers_id
        from
            claim_upload_external a,
            account               b
        where
            employee_id is not null
            and a.employee_id = b.acc_num
            and a.transaction_code in ( 12, 14 )
            and a.pos_flag <> 4
    ) loop
        begin
            l_claim_id := null;
            l_sqlerrm := null;
            select
                count(*)
            into l_count
            from
                metavante_settlements c
            where
                c.settlement_number || c.transaction_date = x.sequence_number || x.trans_date;

            if l_count = 0 then
                insert into metavante_settlements (
                    settlement_number,
                    acc_num,
                    acc_id,
                    merchant_name,
                    transaction_amount,
                    transaction_code,
                    transaction_status,
                    transaction_date,
                    pos_flag,
                    settlement_date,
                    created_claim,
                    claim_id,
                    last_update_date,
                    creation_date,
                    plan_type
                ) values ( x.sequence_number,
                           x.acc_num,
                           x.acc_id,
                           x.merchant_name,
                           x.transaction_amt,
                           x.transaction_code,
                           x.transaction_status,
                           x.trans_date,
                           x.pos_flag,
                           x.settlement_date,
                           'N',
                           null,
                           sysdate,
                           sysdate,
                           x.plan_type );

                insert into claimn (
                    claim_id,
                    pers_id,
                    pers_patient,
                    claim_code,
                    prov_name,
                    claim_date_start,
                    tax_code,
                    service_status,
                    claim_amount,
                    claim_paid,
                    claim_pending,
                    note,
                    service_type,
                    denied_amount,
                    approved_amount,
                    approved_date,
                    claim_status
                ) values ( doc_seq.nextval,
                           x.pers_id,
                           x.pers_id,
                           x.sequence_number || x.settlement_date,
                           x.merchant_name,
                           to_date(substr(x.settlement_date, 1, 8),
                                   'YYYYMMDD'),
                           1,
                           2,
                           x.transaction_amt,
                           x.transaction_amt,
                           0,
                           'Debit Card Claim Created for '
                           || x.sequence_number
                           || '('
                           || to_char(sysdate, 'yyyymmdd')
                           || ')',
                           x.plan_type,
                           x.denied_amount,
                           x.transaction_amt,
                           to_date(x.settlement_date, 'YYYYMMDD'),
                           'PAID' ) returning claim_id into l_claim_id;

                update metavante_settlements
                set
                    created_claim = 'Y',
                    claim_id = l_claim_id
                where
                    settlement_number = x.sequence_number;

                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    claimn_id,
                    note,
                    debit_card_posted,
                    plan_type
                ) values ( change_seq.nextval,
                           x.acc_id,
                           to_date(x.settlement_date, 'YYYYMMDD'),
                           x.transaction_amt,
                           13,
                           l_claim_id,
                           'Debit Card Claim (Claim ID:'
                           || l_claim_id
                           || ') created on '
                           || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                           'Y',
                           x.plan_type );

                l_transaction_count := l_transaction_count + 1;
            end if;

        exception
            when others then
                rollback;
                l_sqlerrm := sqlerrm;
                dbms_output.put_line('error message ' || l_sqlerrm);
        end;
    end loop;

    dbms_output.put_line('l_transaction_count ' || l_transaction_count);
exception
    when l_processed then
        null;
    when l_create_error then
        rollback;
        dbms_output.put_line('error message ' || sqlerrm);
        x_error_status := 'E';
    when others then
        raise;
        l_sqlerrm := sqlerrm;
       /** send email alert as soon as it fails **/
        x_error_status := 'E';
end;

    /*** Manual Claim ***/
/


-- sqlcl_snapshot {"hash":"cd2ee597eae59c4b82b4552cced8e6c7994665e5","type":"PROCEDURE","name":"PROCESS_DEBIT_CARD_CLAIMS","schemaName":"SAMQA","sxml":""}