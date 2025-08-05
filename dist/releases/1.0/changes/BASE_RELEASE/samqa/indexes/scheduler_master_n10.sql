-- liquibase formatted sql
-- changeset SAMQA:1754373933301 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_master_n10.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_master_n10.sql:null:7b2891502c924c10ad377cfc8920cfa4de03ea8f:create

create index samqa.scheduler_master_n10 on
    samqa.scheduler_master (
        calendar_id
    );

