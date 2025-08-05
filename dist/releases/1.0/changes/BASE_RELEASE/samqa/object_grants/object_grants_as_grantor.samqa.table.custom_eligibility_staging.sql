-- liquibase formatted sql
-- changeset SAMQA:1754373939600 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.custom_eligibility_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.custom_eligibility_staging.sql:null:83a4cf7cd012cdb81a7bcbb680b069676489340d:create

grant delete on samqa.custom_eligibility_staging to rl_sam_rw;

grant insert on samqa.custom_eligibility_staging to rl_sam_rw;

grant select on samqa.custom_eligibility_staging to rl_sam_rw;

grant select on samqa.custom_eligibility_staging to rl_sam1_ro;

grant select on samqa.custom_eligibility_staging to rl_sam_ro;

grant update on samqa.custom_eligibility_staging to rl_sam_rw;

