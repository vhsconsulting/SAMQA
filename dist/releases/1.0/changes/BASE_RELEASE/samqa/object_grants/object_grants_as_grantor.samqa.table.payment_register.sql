-- liquibase formatted sql
-- changeset SAMQA:1754373941621 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.payment_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.payment_register.sql:null:6ce0d8907ffee72346f636b8a1a4379d549df6ed:create

grant delete on samqa.payment_register to rl_sam_rw;

grant insert on samqa.payment_register to rl_sam_rw;

grant select on samqa.payment_register to rl_sam1_ro;

grant select on samqa.payment_register to rl_sam_rw;

grant select on samqa.payment_register to rl_sam_ro;

grant update on samqa.payment_register to rl_sam_rw;

