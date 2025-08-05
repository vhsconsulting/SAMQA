-- liquibase formatted sql
-- changeset SAMQA:1754373939523 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.contact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.contact.sql:null:6e372c1d4bf10764e218a36fdd30cb55b7fe47d0:create

grant delete on samqa.contact to rl_sam_rw;

grant insert on samqa.contact to rl_sam_rw;

grant select on samqa.contact to rl_sam1_ro;

grant select on samqa.contact to rl_sam_rw;

grant select on samqa.contact to rl_sam_ro;

grant update on samqa.contact to rl_sam_rw;

