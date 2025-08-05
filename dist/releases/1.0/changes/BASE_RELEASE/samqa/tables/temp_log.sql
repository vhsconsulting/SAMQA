-- liquibase formatted sql
-- changeset SAMQA:1754374163683 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\temp_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/temp_log.sql:null:545c0e98117883ebc8a83f5db0adbf06fe32cba9:create

create table samqa.temp_log (
    message varchar2(2000 byte)
);

