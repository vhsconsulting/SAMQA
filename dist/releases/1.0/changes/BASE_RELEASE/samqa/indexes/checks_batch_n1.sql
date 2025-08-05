-- liquibase formatted sql
-- changeset SAMQA:1754373930010 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\checks_batch_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/checks_batch_n1.sql:null:4dda40dc3ea9edb086e513c80f9395eb977ddf29:create

create index samqa.checks_batch_n1 on
    samqa.checks_batch (
        employer_payment_id
    );

