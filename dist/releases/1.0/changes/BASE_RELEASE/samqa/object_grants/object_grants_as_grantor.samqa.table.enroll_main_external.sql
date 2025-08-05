-- liquibase formatted sql
-- changeset SAMQA:1754373940096 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enroll_main_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enroll_main_external.sql:null:dc2b478cc42b8458ef8f5bf70739a4140967eaef:create

grant select on samqa.enroll_main_external to rl_sam1_ro;

grant select on samqa.enroll_main_external to rl_sam_ro;

