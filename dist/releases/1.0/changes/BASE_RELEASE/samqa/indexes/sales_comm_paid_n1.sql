-- liquibase formatted sql
-- changeset SAMQA:1754373933194 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\sales_comm_paid_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/sales_comm_paid_n1.sql:null:6bd04e0ec7956fc1ed5097844745682bb57b3ace:create

create index samqa.sales_comm_paid_n1 on
    samqa.sales_comm_paid (
        salesrep_id
    );

