-- liquibase formatted sql
-- changeset SAMQA:1754373939377 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.claims_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.claims_external.sql:null:28cf09d0e498e1d63ce5ea881c6555e6c510e21b:create

grant select on samqa.claims_external to rl_sam1_ro;

grant select on samqa.claims_external to rl_sam_ro;

