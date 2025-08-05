-- liquibase formatted sql
-- changeset SAMQA:1754373932788 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_register_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_register_n6.sql:null:964d1a26acdf8c6e4bd0a35dcb0bab3bb94138c4:create

create index samqa.payment_register_n6 on
    samqa.payment_register (
        claim_id
    );

