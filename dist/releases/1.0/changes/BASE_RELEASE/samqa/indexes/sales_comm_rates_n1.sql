-- liquibase formatted sql
-- changeset SAMQA:1754373933218 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_comm_rates_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_comm_rates_n1.sql:null:61fb9d5a894917674a1867098d449fbdff6caeda:create

create index samqa.sales_comm_rates_n1 on
    samqa.sales_comm_rates (
        account_type
    );

