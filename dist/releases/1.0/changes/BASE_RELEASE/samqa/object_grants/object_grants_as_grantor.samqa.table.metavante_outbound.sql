-- liquibase formatted sql
-- changeset SAMQA:1754373941197 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_outbound.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_outbound.sql:null:69c6454322fd9adc1586507b544edd3a4dae706e:create

grant delete on samqa.metavante_outbound to rl_sam_rw;

grant insert on samqa.metavante_outbound to rl_sam_rw;

grant select on samqa.metavante_outbound to rl_sam1_ro;

grant select on samqa.metavante_outbound to rl_sam_rw;

grant select on samqa.metavante_outbound to rl_sam_ro;

grant update on samqa.metavante_outbound to rl_sam_rw;

