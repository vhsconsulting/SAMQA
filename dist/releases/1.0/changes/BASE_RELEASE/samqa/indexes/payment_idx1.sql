-- liquibase formatted sql
-- changeset SAMQA:1754373932673 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_idx1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_idx1.sql:null:83186cf78bb2a0a1402a80751e3da7b51b2446ba:create

create index samqa.payment_idx1 on
    samqa.payment (
        acc_id,
        claim_id
    );

