-- liquibase formatted sql
-- changeset SAMQA:1754374144606 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\migrate_pop_receipts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/migrate_pop_receipts.sql:null:79a79868ac2be26e9b9e63cf6be49f7f859a0954:create

create or replace procedure samqa.migrate_pop_receipts as
begin
    insert into employer_payments (
        employer_payment_id,
        entrp_id,
        check_amount,
        check_number,
        check_date,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        note,
        bank_acct_id,
        payment_register_id,
        list_bill,
        reason_code,
        transaction_date,
        plan_type,
        pay_code,
        transaction_source,
        plan_start_date,
        plan_end_date,
        memo,
        invoice_id
    )
        select
            employer_payments_seq.nextval,
            entrp_id,
            check_amount,
            check_number,
            check_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            'Migrated Amount from Employer Deposits : Setup Fee',
            null,
            null,
            list_bill,
            1,
            check_date,
            null,
            1,
            'RECEIPT',
            null,
            null,
            null,
            null
        from
            (
                select
                    a.entrp_id,
                    check_amount,
                    check_number,
                    check_date,
                    a.creation_date,
                    a.created_by,
                    a.last_update_date,
                    a.last_updated_by,
                    list_bill
                from
                    employer_deposits a,
                    account           b
                where
                        a.entrp_id = b.entrp_id
                    and b.account_type = 'POP'
                    and employer_deposit_id in (
                        select
                            min(employer_deposit_id)
                        from
                            employer_deposits c, account           d
                        where
                                c.entrp_id = d.entrp_id
                            and b.account_type = 'POP'
                            and a.entrp_id = c.entrp_id
                        group by
                            c.entrp_id
                    )
            );

    insert into employer_payments (
        employer_payment_id,
        entrp_id,
        check_amount,
        check_number,
        check_date,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        note,
        bank_acct_id,
        payment_register_id,
        list_bill,
        reason_code,
        transaction_date,
        plan_type,
        pay_code,
        transaction_source,
        plan_start_date,
        plan_end_date,
        memo,
        invoice_id
    )
        select
            employer_payments_seq.nextval,
            entrp_id,
            check_amount,
            check_number,
            check_date,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            'Migrated Amount from Employer Deposits : Setup Fee',
            null,
            null,
            list_bill,
            1,
            check_date,
            null,
            1,
            'RECEIPT',
            null,
            null,
            null,
            null
        from
            (
                select
                    a.entrp_id,
                    check_amount,
                    check_number,
                    check_date,
                    a.creation_date,
                    a.created_by,
                    a.last_update_date,
                    a.last_updated_by,
                    list_bill
                from
                    employer_deposits a,
                    account           b
                where
                        a.entrp_id = b.entrp_id
                    and b.account_type = 'POP'
                    and employer_deposit_id not in (
                        select
                            min(employer_deposit_id)
                        from
                            employer_deposits c, account           d
                        where
                                c.entrp_id = d.entrp_id
                            and b.account_type = 'POP'
                            and a.entrp_id = c.entrp_id
                        group by
                            c.entrp_id
                    )
            );

end;
/

