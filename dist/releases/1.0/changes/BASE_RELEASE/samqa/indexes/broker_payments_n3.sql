-- liquibase formatted sql
-- changeset SAMQA:1754373929912 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_payments_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_payments_n3.sql:null:7b7cdffbff9a8dadc38f6b5178871a743e97eff5:create

create index samqa.broker_payments_n3 on
    samqa.broker_payments (
        bank_acct_id
    );

