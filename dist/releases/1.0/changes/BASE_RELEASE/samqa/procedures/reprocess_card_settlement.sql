-- liquibase formatted sql
-- changeset SAMQA:1754374145661 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\reprocess_card_settlement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/reprocess_card_settlement.sql:null:50d37669ce09faf3f7ec5ce7d3278cba76cb9815:create

create or replace procedure samqa.reprocess_card_settlement as

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
    l_plan_start_date      date;
    l_plan_end_date        date;
    l_card_number          number;
    l_claim_status         varchar2(100);
    l_substantiate_flag    varchar2(1);
    x_error_message        varchar2(100);
    x_error_status         varchar2(100);
begin
    for x in (
        select
            settlement_number                           settlement_seq_number,
            b.pers_id,
            b.acc_id,
            substr(
                pc_person.get_claim_code(b.pers_id),
                1,
                4
            )                                           claim_code,
            a.merchant_name,
            a.transaction_amount,
            a.acc_num                                   employee_id,
            mcc_code,
            transaction_code,
            transaction_status,
            transaction_date,
            approval_code,
            disbursable_balance,
            effective_date,
            pos_flag,
            origin_code,
            pre_auth_hold_balance,
            settlement_date,
            terminal_city,
            terminal_name,
            detail_response_code,
            plan_type,
            pc_person.get_entrp_from_pers_id(b.pers_id) entrp_id,
            plan_start_date,
            plan_end_date,
            card_number,
            b.account_type
        from
            metavante_settlements a,
            account               b
        where
                a.acc_num = b.acc_num
            and a.transaction_code in ( 12, 14 )
            and a.pos_flag <> 4
            and claim_id is null
            and not exists (
                select
                    *
                from
                    metavante_settlements c
                where
                            c.settlement_number || c.transaction_date = a.settlement_number || a.transaction_date
                        and c.acc_num = a.acc_num
                    and c.claim_id is not null
            )
    ) loop
        begin
            l_plan_start_date := null;
            l_plan_end_date := null;

           /*FOR xX IN ( SELECT PLAN_START_DATE, PLAN_END_DATE
                      FROM   BEN_PLAN_ENROLLMENT_SETUP
                      WHERE  NVL(TO_DATE(SUBSTR(X.EFFECTIVE_DATE,1,8),'YYYYMMDD'),TO_DATE(SUBSTR(X.SETTLEMENT_DATE,1,8),'YYYYMMDD'))
                      BETWEEN PLAN_START_DATE AND PLAN_END_DATE
                      AND    ACC_ID= X.acc_id
                      AND    PLAN_TYPE = X.PLAN_TYPE)
           LOOP
              l_plan_start_date := xX.PLAN_START_DATE;
              l_plan_end_date := xX.PLAN_END_DATE;
           END LOOP;*/
            l_claim_status := 'PAID';
           -- Add this when we go live with debit card project
            l_substantiate_flag := 'N';
            if x.account_type in ( 'HRA', 'FSA' ) then
                for xx in (
                    select
                        nvl(allow_substantiation, 'N') allow_substantiation
                    from
                        ben_plan_enrollment_setup
                    where
                            plan_type = x.plan_type
                        and status in ( 'A', 'I' )
                        and plan_start_date = to_date(substr(x.plan_start_date, 1, 8),
        'YYYYMMDD')
                        and plan_end_date = to_date(substr(x.plan_end_date, 1, 8),
        'YYYYMMDD')
                        and acc_id = x.acc_id
                ) loop
                    if xx.allow_substantiation = 'Y' then
                        if x.transaction_status in ( 'AUP1', 'AUP5', 'AUPI' ) then
                            l_substantiate_flag := 'Y';
                        elsif x.transaction_status in ( 'AAA8', 'AAA1', 'AAA4' ) then
                            l_substantiate_flag := 'N';
                        end if;

                    end if;
                end loop;
            end if;

            l_claim_id := null;
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
                service_type,
                note,
                claim_status,
                entrp_id,
                plan_start_date,
                plan_end_date,
                approved_amount,
                approved_date,
                claim_date_end,
                service_start_date,
                service_end_date,
                pay_reason,
                claim_source,
                payment_release_date,
                creation_date,
                last_update_date,
                unsubstantiated_flag,
                mcc_code
            ) values ( doc_seq.nextval,
                       x.pers_id,
                       x.pers_id,
                       x.claim_code || x.settlement_date,
                       x.merchant_name,
                       nvl(to_date(substr(x.settlement_date, 1, 8),
                           'YYYYMMDD'),
                           to_date(substr(x.transaction_date, 1, 8),
                           'YYYYMMDD')),
                       1,
                       2,
                       x.transaction_amount,
                       x.transaction_amount,
                       0,
                       x.plan_type,
                       'Debit Card Claim Created for '
                       || x.settlement_seq_number
                       || '('
                       || to_char(sysdate, 'yyyymmdd')
                       || ')',
                       l_claim_status,
                       x.entrp_id,
                       to_date(substr(x.plan_start_date, 1, 8),
                               'YYYYMMDD'),
                       to_date(substr(x.plan_end_date, 1, 8),
                               'YYYYMMDD'),
                       x.transaction_amount,
                       to_date(x.transaction_date, 'yyyymmddhh24miss'),
                       nvl(to_date(substr(x.settlement_date, 1, 8),
                           'YYYYMMDD'),
                           to_date(substr(x.transaction_date, 1, 8),
                           'YYYYMMDD')) -- CLAIM_DATE_END
                           ,
                       nvl(to_date(substr(x.settlement_date, 1, 8),
                           'YYYYMMDD'),
                           to_date(substr(x.transaction_date, 1, 8),
                           'YYYYMMDD')) -- SERVICE_START_DATE
                           ,
                       nvl(to_date(substr(x.settlement_date, 1, 8),
                           'YYYYMMDD'),
                           to_date(substr(x.transaction_date, 1, 8),
                           'YYYYMMDD')) -- SERVICE_END_DATE
                           ,
                       13,
                       'DEBIT_CARD',
                       to_date(x.settlement_date, 'yyyymmddhh24miss'),
                       sysdate,
                       sysdate,
                       l_substantiate_flag,
                       x.mcc_code ) returning claim_id into l_claim_id;
    --       PC_LOG.LOG_ERROR('SETTLEMENTS,L_CLAIM_ID',L_CLAIM_ID);
            if l_claim_id is not null then
                update metavante_settlements
                set
                    created_claim = 'Y',
                    claim_id = l_claim_id
                where
                        settlement_number || transaction_date = x.settlement_seq_number || x.transaction_date
                    and acc_num = x.employee_id;
                      -- Add this when we go live with debit card project

                if
                    x.account_type in ( 'HRA', 'FSA' )
                    and l_substantiate_flag = 'Y'
                then
                    pc_notifications.debit_letter_notification(x.pers_id, x.acc_id, 'FIRST_LETTER', 0      --System User ID
                    , l_claim_id);

                end if;

                if
                    x.card_number is not null
                    and is_number(x.card_number) = 'Y'
                then
                    l_card_number := to_number ( substr(x.card_number, 13, 4) );
                end if;

                insert into payment (
                    change_num,
                    acc_id,
                    pay_date,
                    amount,
                    reason_code,
                    claimn_id,
                    note,
                    debit_card_posted,
                    plan_type,
                    paid_date,
                    pay_num
                ) values ( change_seq.nextval,
                           x.acc_id,
                           least(
                               nvl(to_date(substr(x.settlement_date, 1, 8),
                                   'YYYYMMDD'),
                                   to_date(substr(x.transaction_date, 1, 8),
                                   'YYYYMMDD')),
                               to_date(substr(x.plan_end_date, 1, 8),
                                 'YYYYMMDD')
                           ),
                           x.transaction_amount,
                           13,
                           l_claim_id,
                           'Debit Card Claim (Claim ID:'
                           || l_claim_id
                           || ') created on '
                           || to_char(sysdate, 'MM/DD/YYYY HH:MI:SS'),
                           'Y',
                           x.plan_type,
                           nvl(to_date(substr(x.settlement_date, 1, 8),
                               'YYYYMMDD'),
                               to_date(substr(x.transaction_date, 1, 8),
                               'YYYYMMDD'))
            -- ,l_card_number);
                               ,
                           x.settlement_seq_number
                           || substr(x.transaction_date, 1, 8) ); -- changed from card number so that the transactions can be unique in GP

                pc_fin.card_claim_fee(x.acc_id, l_claim_id, 'MBI');
                l_transaction_count := l_transaction_count + 1;
            end if;

        exception
            when others then
            -- ROLLBACK;
           --   PC_LOG.LOG_ERROR('SETTLEMENTS',X.SETTLEMENT_SEQ_NUMBER);

                l_utl_id := utl_file.fopen('DEBIT_LOG_DIR', l_file_name, 'w');
                l_sqlerrm := sqlerrm;
                pc_debit_card.insert_alert('Error in settlement file ', l_sqlerrm
                                                                        || ' for settlement_seq_number '
                                                                        || x.settlement_seq_number
                                                                        || ' and account number '
                                                                        || x.employee_id);

                dbms_output.put_line('error message '
                                     || l_sqlerrm
                                     || 'settlement_seq_number '
                                     || x.settlement_seq_number);
           /* mail_utility.send_email('metavante@sterlingadministration.com'
                   ,'vanitha.subramanyam@sterlingadministration.com'
                   ,'Error in Posting  Settlement Records'
                   ,l_sqlerrm);*/
                utl_file.put_line(
                    file   => l_utl_id,
                    buffer => l_sqlerrm
                );
                utl_file.fclose(file => l_utl_id);
        end;
    end loop;

    dbms_output.put_line('l_transaction_count ' || l_transaction_count);
exception
    when l_processed then
        null;
    when l_create_error then
        rollback;
        x_error_message := l_sqlerrm;
        pc_debit_card.insert_alert('Error in settlement file ', l_sqlerrm);
        x_error_status := 'E';
    when others then
        rollback;
        l_sqlerrm := sqlerrm;
        pc_debit_card.insert_alert('Error in settlement file ', l_sqlerrm);

       /** send email alert as soon as it fails **/

        x_error_status := 'E';
end;
/

