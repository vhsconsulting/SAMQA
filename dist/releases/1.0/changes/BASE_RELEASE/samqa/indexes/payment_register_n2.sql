-- liquibase formatted sql
-- changeset SAMQA:1754373932755 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_register_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_register_n2.sql:null:e294242dd946bc5662dc65d42fd95384e262d9cc:create

create index samqa.payment_register_n2 on
    samqa.payment_register (
        acc_num,
        acc_id,
        claim_type
    );

