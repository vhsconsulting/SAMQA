-- liquibase formatted sql
-- changeset SAMQA:1754373936930 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.migrate_billing_contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.migrate_billing_contact.sql:null:3b889d4eec7538869a1367124b257b1c9678aae9:create

grant execute on samqa.migrate_billing_contact to rl_sam_ro;

grant execute on samqa.migrate_billing_contact to rl_sam_rw;

grant execute on samqa.migrate_billing_contact to rl_sam1_ro;

grant debug on samqa.migrate_billing_contact to sgali;

grant debug on samqa.migrate_billing_contact to rl_sam_rw;

grant debug on samqa.migrate_billing_contact to rl_sam1_ro;

