-- liquibase formatted sql
-- changeset SAMQA:1754373939088 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_assignments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_assignments.sql:null:4212c48a0a49efdbed52431d08b7bcf6dbea02a8:create

grant delete on samqa.broker_assignments to rl_sam_rw;

grant insert on samqa.broker_assignments to rl_sam_rw;

grant select on samqa.broker_assignments to rl_sam1_ro;

grant select on samqa.broker_assignments to rl_sam_rw;

grant select on samqa.broker_assignments to rl_sam_ro;

grant update on samqa.broker_assignments to rl_sam_rw;

