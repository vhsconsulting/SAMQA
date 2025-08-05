-- liquibase formatted sql
-- changeset SAMQA:1754374162699 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sales_assignment_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sales_assignment_staging.sql:null:8e259f77f07030d845e1323d0ad5fbdcecd73acf:create

create table samqa.sales_assignment_staging (
    acc_num           varchar2(100 byte),
    salesrep_name     varchar2(1000 byte),
    effective_date    varchar2(100 byte),
    old_salesrep_name varchar2(1000 byte),
    batch_num         number,
    creation_date     date,
    created_by        number,
    last_updated_by   number,
    last_update_date  date,
    salesrep_role     varchar2(50 byte),
    entrp_id          number,
    error_message     varchar2(100 byte),
    status            varchar2(1 byte),
    sales_stag_id     number
);

