-- liquibase formatted sql
-- changeset SAMQA:1754373932729 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\payment_n8.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/payment_n8.sql:null:44e95b7f4eaf05c49672fd3c167cc3306e53f096:create

create index samqa.payment_n8 on
    samqa.payment (
        paid_date
    );

