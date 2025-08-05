-- liquibase formatted sql
-- changeset SAMQA:1754373932682 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_idx2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_idx2.sql:null:4490d7d5206385472285e0a40eb07e9c5ce3e91b:create

create index samqa.payment_idx2 on
    samqa.payment (
        acc_id,
        claimn_id
    );

