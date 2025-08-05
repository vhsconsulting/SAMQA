-- liquibase formatted sql
-- changeset SAMQA:1754373933318 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_master_n4.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_master_n4.sql:null:6b96688d64235ca2fc26ce8fd322b16f37a70922:create

create index samqa.scheduler_master_n4 on
    samqa.scheduler_master (
        payment_method
    );

