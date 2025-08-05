-- liquibase formatted sql
-- changeset SAMQA:1754374147178 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\payment_reason.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/payment_reason.sql:null:3e0d927b8b548797c898a676c145eef9590c014b:create

alter table samqa.payment
    add constraint payment_reason
        foreign key ( reason_code )
            references samqa.pay_reason ( reason_code )
        enable;

