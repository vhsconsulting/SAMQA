-- liquibase formatted sql
-- changeset SAMQA:1754373941118 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_adjustment_outbound.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_adjustment_outbound.sql:null:2bd00570ba518225802bb1f9ee0d304817790a6a:create

grant delete on samqa.metavante_adjustment_outbound to rl_sam_rw;

grant insert on samqa.metavante_adjustment_outbound to rl_sam_rw;

grant select on samqa.metavante_adjustment_outbound to rl_sam1_ro;

grant select on samqa.metavante_adjustment_outbound to rl_sam_rw;

grant select on samqa.metavante_adjustment_outbound to rl_sam_ro;

grant update on samqa.metavante_adjustment_outbound to rl_sam_rw;

