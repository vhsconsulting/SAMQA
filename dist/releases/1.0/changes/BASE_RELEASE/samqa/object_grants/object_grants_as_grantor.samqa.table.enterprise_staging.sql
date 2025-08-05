-- liquibase formatted sql
-- changeset SAMQA:1754373940192 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enterprise_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enterprise_staging.sql:null:8f6cec1ef17a8e87117c3ee45148078fe2cead58:create

grant delete on samqa.enterprise_staging to rl_sam_rw;

grant insert on samqa.enterprise_staging to rl_sam_rw;

grant select on samqa.enterprise_staging to rl_sam1_ro;

grant select on samqa.enterprise_staging to rl_sam_ro;

grant select on samqa.enterprise_staging to rl_sam_rw;

grant update on samqa.enterprise_staging to rl_sam_rw;

