-- liquibase formatted sql
-- changeset SAMQA:1754373929896 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\broker_payments_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/broker_payments_n2.sql:null:e39fd9a845044795aba9d10b08640cb73d59cb7d:create

create index samqa.broker_payments_n2 on
    samqa.broker_payments (
        vendor_id
    );

