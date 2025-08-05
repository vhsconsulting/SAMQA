-- liquibase formatted sql
-- changeset SAMQA:1754374166039 stripComments:false logicalFilePath:BASE_RELEASE\samqa\triggers\payment_bf.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/triggers/payment_bf.sql:null:b7aa2268799ee58df97a9a1612c5e3d80a1f1190:create

create or replace editionable trigger samqa.payment_bf before
    insert or update on samqa.payment
    for each row
begin
    if inserting then
        :new.created_by := get_user_id(v('APP_USER'));
        :new.creation_date := sysdate;
    end if;

    :new.last_updated_by := get_user_id(v('APP_USER'));
    :new.last_updated_date := sysdate;
    if :new.reason_mode is null then
        if
            :new.reason_code in ( 1, 2, 3, 100 )
            and pc_account.fee_bucket_balance(:new.acc_id) >= :new.amount
        then
            :new.reason_mode := 'FP';
        else
            :new.reason_mode := 'P';
        end if;
    end if;

    if
        :new.paid_date is null
        and :new.reason_code in ( 11, 12, 19 )
        and :new.pay_num is not null
    then
        :new.paid_date := :new.pay_date;
    end if;

end;
/

alter trigger samqa.payment_bf enable;

