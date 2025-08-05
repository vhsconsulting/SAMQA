-- liquibase formatted sql
-- changeset SAMQA:1754374162769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_commission_range.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_commission_range.sql:null:d37d97061e5866d64099fac03c8b9a3eba1c59b0:create

create table samqa.sales_commission_range (
    salesrep_role   varchar2(30 byte),
    from_range      number,
    to_range        number,
    comm_percentage number
);

