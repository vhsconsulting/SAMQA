-- liquibase formatted sql
-- changeset SAMQA:1754373931729 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\insure_history_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/insure_history_n1.sql:null:f6060e438fbec2a859f5397b7287005c91d07faf:create

create index samqa.insure_history_n1 on
    samqa.insure_history (
        pers_id
    );

