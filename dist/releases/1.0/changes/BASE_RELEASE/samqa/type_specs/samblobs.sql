-- liquibase formatted sql
-- changeset SAMQA:1754374166338 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\samblobs.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/samblobs.sql:null:3c269c2b9ebb02a7eb349062a969c41a5c81e49c:create

create or replace type samqa.samblobs as
    table of samblob;
/

