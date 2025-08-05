-- liquibase formatted sql
-- changeset SAMQA:1754373929896 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_payments_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_payments_n1.sql:null:0738dee23185eb0c43cf27f62ffa56bfd1f98bb1:create

create index samqa.broker_payments_n1 on
    samqa.broker_payments (
        broker_id
    );

