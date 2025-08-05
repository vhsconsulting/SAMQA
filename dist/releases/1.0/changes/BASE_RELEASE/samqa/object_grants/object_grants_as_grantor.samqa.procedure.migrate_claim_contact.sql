-- liquibase formatted sql
-- changeset SAMQA:1754373936937 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.migrate_claim_contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.migrate_claim_contact.sql:null:4bee7892d8af179940ebd0b60250945a67977e85:create

grant execute on samqa.migrate_claim_contact to rl_sam_ro;

grant execute on samqa.migrate_claim_contact to rl_sam_rw;

grant execute on samqa.migrate_claim_contact to rl_sam1_ro;

grant debug on samqa.migrate_claim_contact to sgali;

grant debug on samqa.migrate_claim_contact to rl_sam_rw;

grant debug on samqa.migrate_claim_contact to rl_sam1_ro;

