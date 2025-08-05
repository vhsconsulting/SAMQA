-- liquibase formatted sql
-- changeset SAMQA:1754373992430 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_debit.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_debit.sql:null:d893bcbae673e237008559e03955f35ff2deb6c6:create

create or replace package body samqa.pc_debit is

----------------------------------------------------
--     update_current_acct_balance
----------------------------------------------------
    procedure update_current_acct_balance is
    begin
        update card_debit
        set
            current_card_value = 0
        where
            current_card_value is null;

        update card_debit
        set
            old_card_value = current_card_value;

        update card_debit
        set
            new_card_value = 0,
            bal_adjust_value = 0,
            current_bal_value = 0,
            current_auth_value = 0;

        for x in (
            select
                c.card_id,
                a.acc_id
            from
                card_debit c,
                account    a
            where
                c.card_id = a.pers_id
        ) loop
            update card_debit
            set
                current_bal_value = pc_account.acc_balance(x.acc_id)
            where
                card_id = x.card_id;

        end loop;

    exception
        when others then
            raise_application_error('-20001', 'Error in Update Debit Current Balance: ' || sqlerrm);
    end update_current_acct_balance;

----------------------------------------------------
--     update_audit_card_value
----------------------------------------------------
    procedure update_audit_card_value is
    begin
        update card_debit
        set
            current_card_value = 0;

        for x in (
            select
                d.ssn,
                d.card_value,
                p.pers_id
            from
                debit_daily_balance d,
                person              p
            where
                d.ssn = p.ssn
        ) loop
            update card_debit
            set
                current_card_value = x.card_value,
                new_card_value = x.card_value
            where
                card_id = x.pers_id;

        end loop;

    exception
        when others then
            raise_application_error('-20001', 'Error in Update Audit Cardvalue: ' || sqlerrm);
    end update_audit_card_value;

----------------------------------------------------
--     update_days_card_settlements
----------------------------------------------------
    procedure update_days_card_settlements is
    begin
        for x in (
            select
                s.pers_id,
                s.payment_amount * t.trans_sign as amount
            from
                eb_settlement  s,
                eb_trans_codes t
            where
                    s.trans_code != '00001101'
                and s.trans_code != '00001102'
                and s.trans_code = t.trans_code
                and s.created_claim = 'Y'
                and trunc(s.file_date) = to_date(sysdate, 'DD-MON-YY')
        ) loop
            update card_debit
            set
                current_card_value = current_card_value + x.amount
            where
                card_id = x.pers_id;

        end loop;
    exception
        when others then
            raise_application_error('-20001', 'Error in Update Audit Cardvalue: ' || sqlerrm);
    end update_days_card_settlements;

----------------------------------------------------
--     update_audit_card_settlements
----------------------------------------------------
    procedure update_audit_card_settlements is
    begin
        for x in (
            select
                s.pers_id,
                s.payment_amount * t.trans_sign as amount
            from
                eb_settlement  s,
                eb_trans_codes t
            where
                    s.trans_code = t.trans_code
                and s.created_claim = 'Y'
                and trunc(s.file_date) = to_date(sysdate, 'DD-MON-YY')
        ) loop
            update card_debit
            set
                current_card_value = current_card_value + x.amount
            where
                card_id = x.pers_id;

        end loop;
    exception
        when others then
            raise_application_error('-20001', 'Error in Update Audit Cardvalue: ' || sqlerrm);
    end update_audit_card_settlements;

end pc_debit;
/

