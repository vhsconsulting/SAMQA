-- liquibase formatted sql
-- changeset SAMQA:1753779553741 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\checks_batch_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/checks_batch_n2.sql:null:4ecb6550283c4a7f7d39b7ea37e8fd505f3397a1:create

create index samqa.checks_batch_n2 on
    samqa.checks_batch (
        cobra_payment_id
    );

