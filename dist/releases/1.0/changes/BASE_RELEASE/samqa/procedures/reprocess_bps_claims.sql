-- liquibase formatted sql
-- changeset SAMQA:1754374145520 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\reprocess_bps_claims.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/reprocess_bps_claims.sql:null:eaebc08d9b86f63a0fb1872c8d26e152c55b286a:create

create or replace procedure samqa.reprocess_bps_claims (
    p_acc_num in varchar2
) is

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
begin

     /*  FOR X IN (SELECT A.ACC_ID , PERS_ID ,ACC_NUM , B.CLAIMN_ID
                 FROM ACCOUNT A, PAYMENT B
                 WHERE ACC_NUM = P_ACC_NUM
                 AND   A.ACC_ID = B.ACC_ID)
       LOOP
         delete from payment_register where acc_num = x.acc_num and claim_id = x.claimn_id;
         delete from payment where acc_id = x.acc_id  and claimn_id = x.claimn_id;
         delete from claimn where pers_id = x.pers_id and claim_id = x.claimn_id;
         delete FROM METAVANTE_SETTLEMENTS
          WHERE acc_num = P_ACC_NUM  and claim_id = x.claimn_id;
       END LOOP;*/

    for x in (
        select
            settlement_seq_number,
            b.pers_id,
            b.acc_id,
            substr(
                pc_person.get_claim_code(b.pers_id),
                1,
                4
            )                                    claim_code,
            a.merchant_name,
            a.transaction_amount,
            employee_id,
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
            transaction_process_code,
            decode(transaction_code, 10, 13, 12) reason_code,
            decode(transaction_code,
                   10,
                   'Disbursement Migrated from BPS for '
                   || a.settlement_seq_number
                   || '('
                   || to_char(sysdate, 'yyyymmdd')
                   || ')',
                   'Debit Card Claim Created for '
                   || a.settlement_seq_number
                   || '('
                   || to_char(sysdate, 'yyyymmdd')
                   || ')')                              description
        from
            settlement_external a,
            account             b
        where
                a.employee_id = b.acc_num
            and a.transaction_code in ( 10, 12, 14 )
            and a.record_id = 'EN'
            and a.transaction_status like 'A%'
            and acc_num = p_acc_num
            and not exists (
                select
                    *
                from
                    metavante_settlements c
                where
                        c.settlement_number || c.transaction_date = a.settlement_seq_number || a.transaction_date
                    and c.acc_num = a.employee_id
            )

                --AND  A.ORIGIN_CODE IN (1,2,3,4)
    ) loop
        begin
            l_claim_id := null;
            l_sqlerrm := null;
            insert into metavante_settlements (
                settlement_number,
                acc_num,
                acc_id,
                merchant_name,
                mcc_code,
                transaction_amount,
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
                created_claim,
                claim_id,
                last_update_date,
                creation_date,
                plan_type
            ) values ( x.settlement_seq_number,
                       x.employee_id,
                       x.acc_id,
                       x.merchant_name,
                       x.mcc_code,
                       x.transaction_amount,
                       x.transaction_code,
                       x.transaction_status,
                       x.transaction_date,
                       x.approval_code,
                       x.disbursable_balance,
                       x.effective_date,
                       x.pos_flag,
                       x.origin_code,
                       x.pre_auth_hold_balance,
                       x.settlement_date,
                       x.terminal_city,
                       x.terminal_name,
                       x.detail_response_code,
                       'N',
                       null,
                       sysdate,
                       sysdate,
                       x.plan_type );

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
                claim_status
            ) values ( doc_seq.nextval,
                       x.pers_id,
                       x.pers_id,
                       'BPS' || x.settlement_date,
                       x.merchant_name,
                       nvl(to_date(substr(x.effective_date, 1, 8),
                           'YYYYMMDD'),
                           to_date(substr(x.transaction_date, 1, 8),
                           'YYYYMMDD')),
                       1,
                       2,
                       x.transaction_amount,
                       x.transaction_amount,
                       0,
                       x.plan_type,
                       x.description,
                       'PAID' ) returning claim_id into l_claim_id;

            dbms_output.put_line('L_CLAIM_ID ' || l_claim_id);
            if l_claim_id is not null then
                update metavante_settlements
                set
                    created_claim = 'Y',
                    claim_id = l_claim_id
                where
                        settlement_number || transaction_date = x.settlement_seq_number || x.transaction_date
                    and acc_num = x.employee_id;

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
                           nvl(to_date(substr(x.effective_date, 1, 8),
                               'YYYYMMDD'),
                               to_date(substr(x.settlement_date, 1, 8),
                               'YYYYMMDD')),
                           x.transaction_amount,
                           x.reason_code,
                           l_claim_id,
                           x.description,
                           'Y',
                           x.plan_type );

            end if;

        exception
            when others then
                dbms_output.put_line('WHEN OTHERS ' || sqlerrm);
                raise;
        end;
    end loop;

    dbms_output.put_line('l_transaction_count ' || l_transaction_count);
exception
    when l_processed then
        dbms_output.put_line('L_PROCESSED ' || sqlerrm);
    when l_create_error then
        dbms_output.put_line('l_create_error ' || sqlerrm);
    when others then
        rollback;
        dbms_output.put_line('l_create_error ' || sqlerrm);

       /** send email alert as soon as it fails **/

end;
/

