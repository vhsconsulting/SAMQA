-- liquibase formatted sql
-- changeset SAMQA:1754374166363 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\v_table_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/v_table_type.sql:null:c6b6a77da946222ffd9b6c4429bb4aa743cfc1fd:create

create or replace type samqa.v_table_type as
    table of v_type;
/

