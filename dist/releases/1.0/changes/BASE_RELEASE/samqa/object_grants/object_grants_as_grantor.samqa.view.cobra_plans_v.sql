-- liquibase formatted sql
-- changeset SAMQA:1754373943408 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cobra_plans_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cobra_plans_v.sql:null:c5f6ebe24aadd621726618da5519634763b1ae15:create

grant select on samqa.cobra_plans_v to rl_sam1_ro;

grant select on samqa.cobra_plans_v to rl_sam_rw;

grant select on samqa.cobra_plans_v to rl_sam_ro;

