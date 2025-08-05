-- liquibase formatted sql
-- changeset SAMQA:1754373939584 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.custom_eligibility_req.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.custom_eligibility_req.sql:null:bebd3fde454fe98da0b1b105c721ca62f15bf92b:create

grant delete on samqa.custom_eligibility_req to rl_sam_rw;

grant insert on samqa.custom_eligibility_req to rl_sam_rw;

grant select on samqa.custom_eligibility_req to rl_sam1_ro;

grant select on samqa.custom_eligibility_req to rl_sam_rw;

grant select on samqa.custom_eligibility_req to rl_sam_ro;

grant update on samqa.custom_eligibility_req to rl_sam_rw;

