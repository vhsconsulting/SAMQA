-- liquibase formatted sql
-- changeset SAMQA:1754374147222 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\plan_fee_code.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/plan_fee_code.sql:null:3c9819a70f2831f02233f400251198ed4c826e65:create

alter table samqa.plan_fee
    add constraint plan_fee_code
        foreign key ( plan_code )
            references samqa.plans ( plan_code )
        enable;

