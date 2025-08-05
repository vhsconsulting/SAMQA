-- liquibase formatted sql
-- changeset SAMQA:1754374147033 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\income_acc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/income_acc.sql:null:362fac48f80af1c90f956c449429ce2e8ec5de14:create

alter table samqa.income
    add constraint income_acc
        foreign key ( acc_id )
            references samqa.account ( acc_id )
        enable;

