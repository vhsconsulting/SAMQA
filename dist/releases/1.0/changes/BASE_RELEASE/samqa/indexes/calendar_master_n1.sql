-- liquibase formatted sql
-- changeset SAMQA:1754373929928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\calendar_master_n1.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/calendar_master_n1.sql:null:be3bfccfc386977342abab38b381c611b71608ea:create

create index samqa.calendar_master_n1 on
    samqa.calendar_master (
        calendar_type
    );

