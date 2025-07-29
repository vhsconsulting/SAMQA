-- liquibase formatted sql
-- changeset SAMQA:1753779556910 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\scheduler_master_n3.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/scheduler_master_n3.sql:null:53b3a32617b1860f101a850060fc47f888b01220:create

create index samqa.scheduler_master_n3 on
    samqa.scheduler_master (
        bank_acct_id
    );

