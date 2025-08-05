-- liquibase formatted sql
-- changeset SAMQA:1754373933287 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_master_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_master_n1.sql:null:604fd85a40b842bcb7369113370d1c6136ca503d:create

create index samqa.scheduler_master_n1 on
    samqa.scheduler_master (
        acc_id
    );

