-- liquibase formatted sql
-- changeset SAMQA:1754374166376 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\varchar2_255_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/varchar2_255_table.sql:null:79d23f0d6cee4a9c31c411df4eb24c7157f98a40:create

create or replace type samqa.varchar2_255_table as
    table of varchar2(255);
/

