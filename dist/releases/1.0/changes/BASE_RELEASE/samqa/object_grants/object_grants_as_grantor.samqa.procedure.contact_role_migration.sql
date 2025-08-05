-- liquibase formatted sql
-- changeset SAMQA:1754373936740 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.contact_role_migration.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.contact_role_migration.sql:null:612e895bb360dbaf1012bcb9f009c9fc2614d22e:create

grant execute on samqa.contact_role_migration to rl_sam_ro;

grant execute on samqa.contact_role_migration to rl_sam_rw;

grant execute on samqa.contact_role_migration to rl_sam1_ro;

grant debug on samqa.contact_role_migration to sgali;

grant debug on samqa.contact_role_migration to rl_sam_rw;

grant debug on samqa.contact_role_migration to rl_sam1_ro;

