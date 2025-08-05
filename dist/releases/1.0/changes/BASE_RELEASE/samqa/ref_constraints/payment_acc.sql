-- liquibase formatted sql
-- changeset SAMQA:1754374147154 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\payment_acc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/payment_acc.sql:null:be0aad9d6276f027647cecd2abe9f263427ab50c:create

alter table samqa.payment
    add constraint payment_acc
        foreign key ( acc_id )
            references samqa.account ( acc_id )
        enable;

