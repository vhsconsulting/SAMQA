-- liquibase formatted sql
-- changeset SAMQA:1754373932772 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_register_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_register_n4.sql:null:bdd9f5c77c03b3a1677b8bf3e0626cded3bf40d0:create

create index samqa.payment_register_n4 on
    samqa.payment_register (
        claim_type
    );

