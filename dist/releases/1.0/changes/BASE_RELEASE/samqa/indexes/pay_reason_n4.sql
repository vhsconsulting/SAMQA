-- liquibase formatted sql
-- changeset SAMQA:1754373932634 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_reason_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_reason_n4.sql:null:e4c7cd2acdc804cc2f4706a5fa2309fffa6d4d84:create

create index samqa.pay_reason_n4 on
    samqa.pay_reason (
        reason_mapping
    );

