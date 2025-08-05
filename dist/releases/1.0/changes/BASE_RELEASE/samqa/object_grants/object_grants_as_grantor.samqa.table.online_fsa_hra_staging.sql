-- liquibase formatted sql
-- changeset SAMQA:1754373941446 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_fsa_hra_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_fsa_hra_staging.sql:null:4a67165cf734ab4fe5874828125463732fbc0d93:create

grant delete on samqa.online_fsa_hra_staging to rl_sam_rw;

grant insert on samqa.online_fsa_hra_staging to rl_sam_rw;

grant select on samqa.online_fsa_hra_staging to rl_sam1_ro;

grant select on samqa.online_fsa_hra_staging to rl_sam_rw;

grant select on samqa.online_fsa_hra_staging to rl_sam_ro;

grant update on samqa.online_fsa_hra_staging to rl_sam_rw;

