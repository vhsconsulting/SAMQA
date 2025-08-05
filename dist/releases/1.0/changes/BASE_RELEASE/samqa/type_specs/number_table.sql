-- liquibase formatted sql
-- changeset SAMQA:1754374166324 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\number_table.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/number_table.sql:null:dbdd489971d295e23744a4cf518e5e4bf89a99d2:create

create or replace type samqa.number_table as
    table of number;
/

