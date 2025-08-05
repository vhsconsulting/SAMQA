-- liquibase formatted sql
-- changeset SAMQA:1754373933234 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_comm_rates_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_comm_rates_n3.sql:null:da4f0e6a36599ce8f444e3546aa02b256182f7f3:create

create index samqa.sales_comm_rates_n3 on
    samqa.sales_comm_rates (
        account_type,
        account_category
    );

