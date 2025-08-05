-- liquibase formatted sql
-- changeset SAMQA:1754373933211 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_comm_paid_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_comm_paid_n3.sql:null:08f3e5e2b3c5ebd5b5b8076937c275fd42409967:create

create index samqa.sales_comm_paid_n3 on
    samqa.sales_comm_paid (
        account_type,
        account_category
    );

