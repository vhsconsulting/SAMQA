-- liquibase formatted sql
-- changeset SAMQA:1754374166351 stripComments:false logicalFilePath:BASE_RELEASE\samqa\type_specs\samclobs.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/type_specs/samclobs.sql:null:df744723a94ca093e2771bd53f54217fd5452cdc:create

create or replace type samqa.samclobs as
    table of samclob;
/

