-- liquibase formatted sql
-- changeset SAMQA:1754373932702 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_n5.sql:null:cb7a7f3bfc82d989cd90cdac2a4108e04468cc6c:create

create index samqa.payment_n5 on
    samqa.payment (
        reason_code
    );

