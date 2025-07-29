create or replace procedure samqa.process_bps_claims (
    p_file_name in varchar2
) as

    l_sqlerrm            varchar2(3200);
    l_batch_number       varchar2(30);
    setup_error exception;
    l_claim_error_flag   varchar2(30);
    l_doc_flag           varchar2(30);
    l_insurance_category varchar2(30);
    l_claim_category     varchar2(30);
    l_service_type       varchar2(30);
    x_return_status      varchar2(30);
    l_pay_reason         number;
    l_claim_id           number;
    l_claim_type         varchar2(30);
    l_vendor_id          number;
    x_error_message      varchar2(3200);
    l_count              number := 0;
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

    l_batch_number := to_char(sysdate, 'YYYYMMDDHHMISS');
    for xx in (
        select distinct
            record_id,
            tpa_id,
            employee_id,
            plan_type,
            trans_date,
            sequence_number,
            claim_amount                                                                                                          app_amt
            ,
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
            decode(pay_provider, 1, 11, 12)                                                                                       pay_reason
            ,
            nvl(claim_amount, 0) + nvl(denied_amount, 0) + nvl(deductible_amount, 0) + nvl(pended_amount, 0) + nvl(offset_amt, 0) claim_amount
            ,
            b.acc_num
        from
            claim_upload_external a,
            account               b
        where
            employee_id is not null
            and a.employee_id = b.acc_num
--	AND PARTIAL_AUTH  <> 0
            and transaction_process_code = 1
            and transaction_code = 10
            and plan_type <> 'HSA'
            and last_updated <> 't00965edi'
            and not exists (
                select
                    *
                from
                    payment_register
                where
                        payment_register.acc_num = b.acc_num
                    and claim_code = 'BPS' || a.sequence_number
            )
    ) loop
        select
            count(*)
        into l_count
        from
            payment_register
        where
                claim_code = 'BPS' || xx.sequence_number
            and acc_num = xx.acc_num;
     --  DBMS_OUTPUT.PUT_LINE('Manual claim '||XX.MANUAL_CLAIM_NUMBER||' Exist'||' FOR '||XX.ACC_NUM);
        if l_count = 0 then
            l_vendor_id := null;
            if xx.pay_provider = 0 then
                for x in (
                    select
                        x.acc_num,
                        x.acc_id,
                        x.vendor_id,
                        c.first_name
                        || ' '
                        || c.middle_name
                        || ' '
                        || c.last_name name,
                        c.address,
                        c.city,
                        c.state,
                        c.zip
                    from
                        (
                            select
                                a.vendor_id,
                                b.acc_id,
                                b.pers_id,
                                b.acc_num,
                                a.address1,
                                a.city,
                                a.state,
                                a.zip
                            from
                                vendors a,
                                account b
                            where
                                    a.orig_sys_vendor_ref (+) = xx.employee_id
                                and b.acc_num = xx.employee_id
                                and a.orig_sys_vendor_ref (+) = b.acc_num
                        )      x,
                        person c
                    where
                            x.pers_id = c.pers_id
                        and ( x.address1 is null
                              or x.address1 = c.address )
                        and ( x.city is null
                              or x.city = c.city )
                        and ( x.state is null
                              or x.state = c.state )
                        and ( x.zip is null
                              or x.zip = c.zip )
                ) loop
                    l_vendor_id := x.vendor_id;
                end loop;

            end if;

            if l_vendor_id is null then
                for x in (
                    select
                        decode(xx.pay_provider, 1, xx.merchant_name, first_name
                                                                     || ' '
                                                                     || last_name)                                              name,
                        address,
                        city,
                        state,
                        zip,
                        b.acc_id,
                        decode(xx.pay_provider, 1, xx.provider_id, xx.employee_id) orig_sys_vendor_ref
                    from
                        person  a,
                        account b
                    where
                            a.pers_id = b.pers_id
                        and b.acc_num = xx.employee_id
                ) loop
                    pc_payee.add_payee(
                        p_payee_name          => x.name,
                        p_payee_acc_num       => xx.employee_id,
                        p_address             => x.address,
                        p_city                => x.city,
                        p_state               => x.state,
                        p_zipcode             => x.zip,
                        p_acc_num             => xx.employee_id,
                        p_user_id             => 0,
                        p_orig_sys_vendor_ref => x.orig_sys_vendor_ref,
                        p_acc_id              => x.acc_id,
                        p_payee_type          => xx.plan_type,
                        p_payee_tax_id        => null,
                        x_vendor_id           => l_vendor_id,
                        x_return_status       => x_return_status,
                        x_error_message       => x_error_message
                    );

                /*    IF X_RETURN_STATUS = 'E' THEN
                       RAISE setup_error;
                    END IF;*/
                end loop;
            end if;

            select
                doc_seq.nextval
            into l_claim_id
            from
                dual;

            insert into payment_register (
                payment_register_id,
                batch_number,
                acc_num,
                acc_id,
                pers_id,
                provider_name,
                vendor_id,
                vendor_orig_sys,
                claim_code,
                claim_id,
                trans_date,
                gl_account,
                cash_account,
                claim_amount,
                note,
                claim_type,
                service_start_date,
                service_end_date,
                service_type,
                peachtree_interfaced,
                claim_error_flag,
                insufficient_fund_flag,
                date_of_service,
                patient_name,
                pay_reason,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                entrp_id
            )
                select
                    payment_register_seq.nextval,
                    l_batch_number,
                    xx.employee_id,
                    a.acc_id,
                    b.pers_id,
                    decode(xx.pay_provider, 1, xx.merchant_name, 'Paid to Subscriber'),
                    vendor_id,
                    xx.provider_id,
                    'BPS' || xx.sequence_number,
                    l_claim_id,
                    to_date(substr(xx.settlement_date, 1, 8),
                            'YYYYMMDD'),
                    null,
                    null,
                    xx.claim_amount,
                    'Claim from BPS system',
                    decode(xx.pay_provider, 1, 'PROVIDER_FROM_BPS', 'SUBSCRIBER_FROM_BPS'),
                    to_date(substr(xx.settlement_date, 1, 8),
                            'YYYYMMDD'),
                    null,
                    xx.plan_type,
                    'N',
                    'N',
                    'N',
                    to_date(substr(xx.settlement_date, 1, 8),
                            'YYYYMMDD'),
                    b.first_name
                    || ' '
                    || b.last_name,
                    decode(xx.pay_provider, 1, 11, 12),
                    sysdate,
                    0,
                    sysdate,
                    0,
                    b.entrp_id
                from
                    account a,
                    person  b,
                    vendors c
                where
                        a.acc_num = c.acc_num
                    and a.pers_id = b.pers_id
                    and a.acc_num = xx.employee_id
                    and a.acc_id = xx.acc_id
                    and c.vendor_id = l_vendor_id;

            insert into claimn (
                claim_id,
                pers_id,
                pers_patient,
                claim_code,
                prov_name,
                claim_date_start,
                claim_date_end,
                service_status,
                service_start_date,
                service_end_date,
                service_type,
                claim_amount,
                claim_paid,
                claim_pending,
                approved_amount,
                denied_amount,
                approved_date,
                claim_status,
                doc_flag,
                note,
                entrp_id
            )
                select
                    claim_id,
                    pers_id,
                    pers_id,
                    claim_code,
                    provider_name,
                    trans_date,
                    trans_date,
                    2,
                    service_start_date,
                    service_end_date,
                    xx.plan_type,
                    claim_amount,
                    xx.transaction_amt,
                    xx.pended_amount,
                    xx.transaction_amt,
                    xx.denied_amount,
                    to_date(xx.settlement_date, 'YYYYMMDD'),
                    'PAID',
                    'Y',
                    a.note,
                    a.entrp_id
                from
                    payment_register a
                where
                    a.claim_id = l_claim_id;

            if xx.deductible_amount > 0 then
                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    claimn_id,
                    pay_num,
                    note,
                    debit_card_posted,
                    plan_type
                ) values ( change_seq.nextval,
                           xx.acc_id,
                           to_date(xx.settlement_date, 'YYYYMMDD'),
                           xx.transaction_amt,
                           24,
                           l_claim_id,
                           xx.check_number,
                           'Disbursement (Claim ID:'
                           || l_claim_id
                           || ') created on '
                           || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                           'Y',
                           xx.plan_type );

            else
                insert into checks (
                    check_id,
                    acc_id,
                    check_number,
                    check_amount,
                    check_date,
                    entity_type,
                    entity_id,
                    source_system,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by
                ) values ( checks_seq.nextval,
                           xx.acc_id,
                           xx.check_number,
                           xx.transaction_amt,
                           to_date(xx.check_date, 'YYYYMMDD'),
                           'CLAIMN',
                           l_claim_id,
                           'BPS',
                           sysdate,
                           0,
                           sysdate,
                           0 );

                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    claimn_id,
                    pay_num,
                    note,
                    debit_card_posted,
                    plan_type
                ) values ( change_seq.nextval,
                           xx.acc_id,
                           to_date(xx.settlement_date, 'YYYYMMDD'),
                           xx.transaction_amt,
                           xx.pay_reason,
                           l_claim_id,
                           xx.check_number,
                           'Disbursement (Claim ID:'
                           || l_claim_id
                           || ') created on '
                           || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                           'Y',
                           xx.plan_type );

            end if;

        end if;

    end loop;

end;
/


-- sqlcl_snapshot {"hash":"5da3ba4b1003edef26e7c54c8cea8afbebcdded0","type":"PROCEDURE","name":"PROCESS_BPS_CLAIMS","schemaName":"SAMQA","sxml":""}