-- liquibase formatted sql
-- changeset SAMQA:1753779556281 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_reason_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_reason_n3.sql:null:b97c3644daec0e0046913f8f500ac3c20249c12f:create

create index samqa.pay_reason_n3 on
    samqa.pay_reason (
        reason_type
    );

