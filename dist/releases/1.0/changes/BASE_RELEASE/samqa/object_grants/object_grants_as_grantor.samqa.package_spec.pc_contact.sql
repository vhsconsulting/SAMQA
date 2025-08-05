-- liquibase formatted sql
-- changeset SAMQA:1754373936018 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_contact.sql:null:65b3e91a3c8c29ebdf98995e2a3e31d44ea2c7cf:create

grant execute on samqa.pc_contact to rl_sam_ro;

grant execute on samqa.pc_contact to rl_sam_rw;

grant execute on samqa.pc_contact to rl_sam1_ro;

grant debug on samqa.pc_contact to rl_sam_ro;

grant debug on samqa.pc_contact to sgali;

grant debug on samqa.pc_contact to rl_sam_rw;

grant debug on samqa.pc_contact to rl_sam1_ro;

