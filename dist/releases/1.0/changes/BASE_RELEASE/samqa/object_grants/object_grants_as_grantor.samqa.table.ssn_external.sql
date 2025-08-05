-- liquibase formatted sql
-- changeset SAMQA:1754373942206 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ssn_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ssn_external.sql:null:0ecadb790c7cfd7aa3a49d34f10e03511dccb381:create

grant select on samqa.ssn_external to rl_sam1_ro;

grant select on samqa.ssn_external to rl_sam_ro;

