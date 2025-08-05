-- liquibase formatted sql
-- changeset SAMQA:1754373933327 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_master_n5.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_master_n5.sql:null:45c9a99d0ead36c0d19e9e25c8c1790d8e92082f:create

create index samqa.scheduler_master_n5 on
    samqa.scheduler_master ( trunc(payment_start_date),
    trunc(payment_end_date) );

