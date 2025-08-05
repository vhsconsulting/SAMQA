create or replace procedure samqa.substantiate_previous_year (
    p_claim_id              in number,
    p_substantiation_reason in varchar2,
    p_user_id               in number,
    p_offset_amount         in number,
    p_service_type          in varchar2
) is

    l_claim_id        number;
    l_error_message   varchar2(3200);
    l_return_status   varchar2(255);
    l_plan_start_date date;
    l_plan_end_date   date;
    l_acc_balance     number := 0;
begin
    for x in (
        select
            a.claim_id,
            b.acc_num,
            b.pers_id,
            service_start_date,
            service_end_date,
            a.vendor_id,
            a.service_type,
            b.acc_id,
            b.account_type
        from
            claimn  a,
            account b
        where
                a.pers_id = b.pers_id
            and a.claim_id = p_claim_id
    ) loop
        if p_substantiation_reason = 'PREVIOUS_YEAR' then
            for xx in (
                select
                    max(plan_start_date)           plan_start_date,
                    max(plan_end_date)             plan_end_date,
                    pc_account.acc_balance(acc_id,
                                           max(plan_start_date),
                                           max(plan_end_date),
                                           x.account_type,
                                           plan_type,
                                           max(plan_start_date),
                                           max(plan_end_date)) acc_balance
                from
                    ben_plan_enrollment_setup
                where
                        plan_end_date < sysdate
                    and acc_id = x.acc_id
                    and status in ( 'A', 'I' )
                    and plan_type = x.service_type
                group by
                    acc_id,
                    x.account_type,
                    plan_type
            ) loop
                if xx.acc_balance <= 0 then
                    raise_application_error('-20001', 'Account does not have enough balance to offset for previous year ');
                else
                    l_plan_start_date := xx.plan_start_date;
                    l_plan_end_date := xx.plan_end_date;
                    l_acc_balance := xx.acc_balance;
                end if;
            end loop;

            if
                l_plan_start_date is not null
                and l_plan_end_date is not null
                and least(p_offset_amount, l_acc_balance) > 0
            then
                pc_claim.create_fsa_disbursement(
                    p_acc_num            => x.acc_num,
                    p_acc_id             => x.acc_id,
                    p_vendor_id          => null,
                    p_vendor_acc_num     => null,
                    p_amount             => least(p_offset_amount, l_acc_balance),
                    p_patient_name       => null,
                    p_note               => 'Offset for Debit Card Purchase Claim #' || p_claim_id,
                    p_user_id            => p_user_id,
                    p_service_start_date => l_plan_start_date,
                    p_service_end_date   => l_plan_end_date,
                    p_date_received      => sysdate,
                    p_service_type       => nvl(p_service_type, x.service_type),
                    p_claim_source       => 'DEBIT_CARD_OFFSET',
                    p_claim_method       => 'DEBIT_CARD_OFFSET',
                    p_bank_acct_id       => null,
                    p_pay_reason         => 73,
                    p_doc_flag           => 'N',
                    p_insurance_category => null,
                    p_claim_category     => null,
                    p_memo               => null,
                    x_claim_id           => l_claim_id,
                    x_return_status      => l_return_status,
                    x_error_message      => l_error_message
                );

                dbms_output.put_line('l_error_message ' || l_error_message);
                dbms_output.put_line('l_return_status ' || l_return_status);
                dbms_output.put_line('l_claim_id ' || l_claim_id);
                if l_return_status <> 'S' then
                    raise_application_error('-20001', l_error_message);
                else
                    if l_claim_id is not null then
                        insert into payment (
                            change_num,
                            acc_id,
                            pay_date,
                            amount,
                            reason_code,
                            claimn_id,
                            pay_num,
                            note,
                            plan_type,
                            paid_date
                        ) values ( change_seq.nextval,
                                   x.acc_id,
                                   l_plan_end_date,
                                   least(p_offset_amount, l_acc_balance),
                                   73,
                                   l_claim_id,
                                   change_seq.currval,
                                   'Disbursement (Claim ID:'
                                   || l_claim_id
                                   || ') created on '
                                   || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                                   nvl(p_service_type, x.service_type),
                                   sysdate );

                        update claimn
                        set
                            substantiation_reason = 'OFFSET_PREVIOUS_YEAR',
                            source_claim_id = p_claim_id,
                            unsubstantiated_flag = 'N',
                            plan_start_date = l_plan_start_date,
                            plan_end_date = l_plan_end_date,
                            reviewed_date = sysdate,
                            approved_date = sysdate,
                            released_date = sysdate,
                            released_by = p_user_id,
                            payment_release_date = sysdate,
                            payment_released_by = p_user_id,
                            claim_status = 'PAID',
                            last_update_date = sysdate,
                            last_updated_by = p_user_id,
                            claim_paid = least(p_offset_amount, l_acc_balance),
                            approved_amount = least(p_offset_amount, l_acc_balance),
                            claim_pending = 0
                        where
                            claim_id = l_claim_id;

                    end if;
                end if;

            else
                raise_application_error('-20001', 'Cannot determine plan year for this plan, Cannot create  ');
            end if;

        end if;

        pc_debit_card.debit_card_offset(
            p_claim_id      => p_claim_id,
            p_amount        => least(p_offset_amount, l_acc_balance),
            p_reason        => 'OFFSET_PREVIOUS_YEAR',
            p_user_id       => p_user_id,
            x_error_message => l_error_message,
            x_return_status => l_return_status
        );

        dbms_output.put_line('l_error_message ' || l_error_message);
        dbms_output.put_line('l_return_status ' || l_return_status);
        if l_return_status <> 'S' then
            raise_application_error('-20001', l_error_message);
        end if;
        update claimn
        set
            note = note
                   || ' *** Offset with manual claim '
                   || l_claim_id
                   || ' on '
                   || to_char(sysdate, 'mm/dd/yyyy hh:mi:ss'),
            last_update_date = sysdate,
            last_updated_by = p_user_id
        where
            claim_id = p_claim_id;

    end loop;
end;
/


-- sqlcl_snapshot {"hash":"f62a84859d1c9a7e89a8e5e970afaada64851bc8","type":"PROCEDURE","name":"SUBSTANTIATE_PREVIOUS_YEAR","schemaName":"SAMQA","sxml":""}