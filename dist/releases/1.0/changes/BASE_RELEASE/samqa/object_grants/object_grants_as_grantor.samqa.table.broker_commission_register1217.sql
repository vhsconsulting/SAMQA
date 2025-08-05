-- liquibase formatted sql
-- changeset SAMQA:1754373939115 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_commission_register1217.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_commission_register1217.sql:null:3274d699095ee33bf70105b83bb6abafec8ebfdf:create

grant delete on samqa.broker_commission_register1217 to rl_sam_rw;

grant insert on samqa.broker_commission_register1217 to rl_sam_rw;

grant select on samqa.broker_commission_register1217 to rl_sam1_ro;

grant select on samqa.broker_commission_register1217 to rl_sam_ro;

grant select on samqa.broker_commission_register1217 to rl_sam_rw;

grant update on samqa.broker_commission_register1217 to rl_sam_rw;

