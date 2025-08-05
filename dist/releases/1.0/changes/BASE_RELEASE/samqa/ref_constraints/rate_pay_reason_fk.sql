-- liquibase formatted sql
-- changeset SAMQA:1754374147243 stripComments:false logicalFilePath:BASE_RELEASE\samqa\ref_constraints\rate_pay_reason_fk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/ref_constraints/rate_pay_reason_fk.sql:null:8359cabb76c9931d4f91c036cc9cd04ef85673e8:create

alter table samqa.rate_structure
    add constraint rate_pay_reason_fk
        foreign key ( rate_id )
            references samqa.pay_reason ( reason_code )
        enable;

