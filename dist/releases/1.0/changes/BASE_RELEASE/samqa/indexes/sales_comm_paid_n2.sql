-- liquibase formatted sql
-- changeset SAMQA:1754373933202 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_comm_paid_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_comm_paid_n2.sql:null:728243c4a1be9378470b12abf48addbc46c1131d:create

create index samqa.sales_comm_paid_n2 on
    samqa.sales_comm_paid (
        account_type
    );

