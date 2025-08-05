-- liquibase formatted sql
-- changeset SAMQA:1754374166304 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\listfile_tbl_typ.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/listfile_tbl_typ.sql:null:5a46e515ba1f11998255ac4c88c540f274102b92:create

create or replace type samqa.listfile_tbl_typ as
    table of listfile_typ;
/

