-- liquibase formatted sql
-- changeset SAMQA:1754373929912 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_payments_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_payments_n4.sql:null:90cb3fc932f7e546484d92d10fe887f3b580070a:create

create index samqa.broker_payments_n4 on
    samqa.broker_payments (
        transaction_number
    );

