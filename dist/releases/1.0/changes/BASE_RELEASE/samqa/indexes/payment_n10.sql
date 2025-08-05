-- liquibase formatted sql
-- changeset SAMQA:1754373932693 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_n10.sql:null:4646a9733bc8f81a5eb01e4d1e5c1f563feaaff9:create

create index samqa.payment_n10 on
    samqa.payment (
        claim_id
    );

