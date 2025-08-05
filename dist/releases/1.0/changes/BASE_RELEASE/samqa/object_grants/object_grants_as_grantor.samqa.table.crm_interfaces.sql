-- liquibase formatted sql
-- changeset SAMQA:1754373939576 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.crm_interfaces.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.crm_interfaces.sql:null:b4bb9aaefa735b298070df0e7bd39141e04e85b4:create

grant delete on samqa.crm_interfaces to rl_sam_rw;

grant insert on samqa.crm_interfaces to rl_sam_rw;

grant select on samqa.crm_interfaces to rl_sam_ro;

grant select on samqa.crm_interfaces to rl_sam1_ro;

grant select on samqa.crm_interfaces to rl_sam_rw;

grant update on samqa.crm_interfaces to rl_sam_rw;

