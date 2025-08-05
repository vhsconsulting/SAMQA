-- liquibase formatted sql
-- changeset SAMQA:1754373939976 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_online_enrollment.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_online_enrollment.sql:null:50ebe3a24e5ef6c6019f56f8a2f302f057fcc417:create

grant delete on samqa.employer_online_enrollment to rl_sam_rw;

grant insert on samqa.employer_online_enrollment to rl_sam_rw;

grant select on samqa.employer_online_enrollment to rl_sam1_ro;

grant select on samqa.employer_online_enrollment to rl_sam_rw;

grant select on samqa.employer_online_enrollment to rl_sam_ro;

grant update on samqa.employer_online_enrollment to rl_sam_rw;

