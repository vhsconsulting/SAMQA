-- liquibase formatted sql
-- changeset SAMQA:1754373941702 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.plan_employer_contacts_stage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.plan_employer_contacts_stage.sql:null:172d70d932ef606d713dfe0a9e18a7ecd6f9ff28:create

grant delete on samqa.plan_employer_contacts_stage to rl_sam_rw;

grant insert on samqa.plan_employer_contacts_stage to rl_sam_rw;

grant select on samqa.plan_employer_contacts_stage to rl_sam1_ro;

grant select on samqa.plan_employer_contacts_stage to rl_sam_ro;

grant select on samqa.plan_employer_contacts_stage to rl_sam_rw;

grant update on samqa.plan_employer_contacts_stage to rl_sam_rw;

