-- liquibase formatted sql
-- changeset SAMQA:1754373933335 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_master_n6.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_master_n6.sql:null:4811dfe867497c487528078e205837e89d1f2fbf:create

create index samqa.scheduler_master_n6 on
    samqa.scheduler_master (
        payment_start_date,
        payment_end_date
    );

