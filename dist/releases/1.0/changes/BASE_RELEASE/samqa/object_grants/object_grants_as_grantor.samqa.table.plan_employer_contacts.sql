-- liquibase formatted sql
-- changeset SAMQA:1754373941694 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.plan_employer_contacts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.plan_employer_contacts.sql:null:fb4184190d5591ff2d1c26109e5048bec2b7c2bd:create

grant delete on samqa.plan_employer_contacts to rl_sam_rw;

grant insert on samqa.plan_employer_contacts to rl_sam_rw;

grant select on samqa.plan_employer_contacts to rl_sam1_ro;

grant select on samqa.plan_employer_contacts to rl_sam_ro;

grant select on samqa.plan_employer_contacts to rl_sam_rw;

grant update on samqa.plan_employer_contacts to rl_sam_rw;

