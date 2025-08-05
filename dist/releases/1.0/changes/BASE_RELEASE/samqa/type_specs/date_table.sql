-- liquibase formatted sql
-- changeset SAMQA:1754374166298 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\date_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/date_table.sql:null:864bdfa526598a5a2c86ef259cbbe9630bc68dd4:create

create or replace type samqa.date_table as
    table of date;
/

