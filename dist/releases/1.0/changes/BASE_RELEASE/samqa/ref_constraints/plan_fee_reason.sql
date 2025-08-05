-- liquibase formatted sql
-- changeset SAMQA:1754374147233 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\plan_fee_reason.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/plan_fee_reason.sql:null:43fedec79412977a3697af1d2755aef37ddfde9e:create

alter table samqa.plan_fee
    add constraint plan_fee_reason
        foreign key ( fee_code )
            references samqa.pay_reason ( reason_code )
        enable;

