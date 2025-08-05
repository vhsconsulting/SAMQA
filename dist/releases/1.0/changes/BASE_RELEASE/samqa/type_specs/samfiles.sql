-- liquibase formatted sql
-- changeset SAMQA:1754374166357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\samfiles.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/samfiles.sql:null:34c79f1db914d0a000d5d4dc21d5481026162d8f:create

create or replace type samqa.samfiles as
    table of varchar2(32000);
/

