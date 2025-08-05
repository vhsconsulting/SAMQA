-- liquibase formatted sql
-- changeset SAMQA:1754373940545 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fsa_enrollments_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fsa_enrollments_external.sql:null:8e2e9b15cb96b6cd6be8e6f8a3e026faf2f05ac7:create

grant select on samqa.fsa_enrollments_external to rl_sam1_ro;

grant select on samqa.fsa_enrollments_external to rl_sam_ro;

