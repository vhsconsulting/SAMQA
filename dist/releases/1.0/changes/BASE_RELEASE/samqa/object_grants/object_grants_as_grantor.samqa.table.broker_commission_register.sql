-- liquibase formatted sql
-- changeset SAMQA:1754373939105 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.broker_commission_register.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.broker_commission_register.sql:null:7be315cad90b508521f188d7e5670e784ec4785a:create

grant delete on samqa.broker_commission_register to rl_sam_rw;

grant insert on samqa.broker_commission_register to rl_sam_rw;

grant select on samqa.broker_commission_register to rl_sam1_ro;

grant select on samqa.broker_commission_register to rl_sam_rw;

grant select on samqa.broker_commission_register to rl_sam_ro;

grant update on samqa.broker_commission_register to rl_sam_rw;

