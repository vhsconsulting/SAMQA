-- liquibase formatted sql
-- changeset SAMQA:1754373941606 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.payment1217.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.payment1217.sql:null:5c5cc4b41f1d929523f9407bdfbb96a8ff7c23ec:create

grant delete on samqa.payment1217 to rl_sam_rw;

grant insert on samqa.payment1217 to rl_sam_rw;

grant select on samqa.payment1217 to rl_sam1_ro;

grant select on samqa.payment1217 to rl_sam_ro;

grant select on samqa.payment1217 to rl_sam_rw;

grant update on samqa.payment1217 to rl_sam_rw;

