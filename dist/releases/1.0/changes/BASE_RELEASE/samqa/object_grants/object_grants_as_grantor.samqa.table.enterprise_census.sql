-- liquibase formatted sql
-- changeset SAMQA:1754373940185 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.enterprise_census.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.enterprise_census.sql:null:5aa68338bd4aa5f4b5a3ea5d05c219ccc36bd45b:create

grant delete on samqa.enterprise_census to rl_sam_rw;

grant insert on samqa.enterprise_census to rl_sam_rw;

grant select on samqa.enterprise_census to rl_sam1_ro;

grant select on samqa.enterprise_census to rl_sam_rw;

grant select on samqa.enterprise_census to rl_sam_ro;

grant update on samqa.enterprise_census to rl_sam_rw;

