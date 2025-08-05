-- liquibase formatted sql
-- changeset SAMQA:1754373941388 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_compliance_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_compliance_staging.sql:null:a611248fcaedff78038c38c042dd497b1b01a22b:create

grant delete on samqa.online_compliance_staging to rl_sam_rw;

grant insert on samqa.online_compliance_staging to rl_sam_rw;

grant select on samqa.online_compliance_staging to rl_sam1_ro;

grant select on samqa.online_compliance_staging to rl_sam_ro;

grant select on samqa.online_compliance_staging to rl_sam_rw;

grant update on samqa.online_compliance_staging to rl_sam_rw;

