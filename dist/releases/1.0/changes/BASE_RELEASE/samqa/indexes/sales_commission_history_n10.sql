-- liquibase formatted sql
-- changeset SAMQA:1754373933249 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_commission_history_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_commission_history_n10.sql:null:b8aad7999d9e7fa23778f7820d887c3df4b50870:create

create index samqa.sales_commission_history_n10 on
    samqa.sales_commission_history (
        ssn
    );

