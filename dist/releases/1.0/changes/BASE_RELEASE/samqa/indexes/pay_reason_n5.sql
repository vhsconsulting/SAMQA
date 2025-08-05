-- liquibase formatted sql
-- changeset SAMQA:1754373932645 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_reason_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_reason_n5.sql:null:1faff748051757ced9463ce2cdff929bdc61c390:create

create index samqa.pay_reason_n5 on
    samqa.pay_reason (
        product_type
    );

