-- liquibase formatted sql
-- changeset SAMQA:1754373933226 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_comm_rates_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_comm_rates_n2.sql:null:628d679388d2474a9a94412b6a827f6606db6820:create

create index samqa.sales_comm_rates_n2 on
    samqa.sales_comm_rates (
        account_category
    );

