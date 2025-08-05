-- liquibase formatted sql
-- changeset SAMQA:1754374166369 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\v_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/v_type.sql:null:07344602d9bb28fe97acfc97ad11698ce18b576b:create

create or replace type samqa.v_type as object (
    v_num number
);
/

