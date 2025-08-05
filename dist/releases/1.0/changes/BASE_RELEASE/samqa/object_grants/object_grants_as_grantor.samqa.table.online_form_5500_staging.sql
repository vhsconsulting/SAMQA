-- liquibase formatted sql
-- changeset SAMQA:1754373941429 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_form_5500_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_form_5500_staging.sql:null:569becab2ac924e44a4ba09371b83dba9ab041a6:create

grant delete on samqa.online_form_5500_staging to rl_sam_rw;

grant insert on samqa.online_form_5500_staging to rl_sam_rw;

grant select on samqa.online_form_5500_staging to rl_sam1_ro;

grant select on samqa.online_form_5500_staging to rl_sam_ro;

grant select on samqa.online_form_5500_staging to rl_sam_rw;

grant update on samqa.online_form_5500_staging to rl_sam_rw;

