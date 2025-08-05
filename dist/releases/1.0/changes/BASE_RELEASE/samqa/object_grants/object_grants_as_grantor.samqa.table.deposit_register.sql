-- liquibase formatted sql
-- changeset SAMQA:1754373939784 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.deposit_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.deposit_register.sql:null:8a7def974596c286b73a5cd2fcf0be3067a0cb5d:create

grant delete on samqa.deposit_register to rl_sam_rw;

grant insert on samqa.deposit_register to rl_sam_rw;

grant select on samqa.deposit_register to rl_sam1_ro;

grant select on samqa.deposit_register to rl_sam_rw;

grant select on samqa.deposit_register to rl_sam_ro;

grant update on samqa.deposit_register to rl_sam_rw;

