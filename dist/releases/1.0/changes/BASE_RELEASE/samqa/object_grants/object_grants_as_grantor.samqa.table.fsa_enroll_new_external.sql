-- liquibase formatted sql
-- changeset SAMQA:1754373940540 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fsa_enroll_new_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fsa_enroll_new_external.sql:null:25313e8bb5e1b846a8ca0bac1954bef6e5be526d:create

grant select on samqa.fsa_enroll_new_external to rl_sam1_ro;

grant select on samqa.fsa_enroll_new_external to rl_sam_ro;

