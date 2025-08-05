-- liquibase formatted sql
-- changeset SAMQA:1754374166382 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\varchar2_4000_tbl.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/varchar2_4000_tbl.sql:null:049aa39ba37fc44675aec1ac7d6386a967068567:create

create or replace type samqa.varchar2_4000_tbl as
    table of varchar2(4000)
/

