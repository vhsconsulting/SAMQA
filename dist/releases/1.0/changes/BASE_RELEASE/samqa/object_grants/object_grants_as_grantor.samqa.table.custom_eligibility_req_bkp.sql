-- liquibase formatted sql
-- changeset SAMQA:1754373939592 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.custom_eligibility_req_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.custom_eligibility_req_bkp.sql:null:dc46a15eea2411092e783d44c19710d9c561e1a3:create

grant delete on samqa.custom_eligibility_req_bkp to rl_sam_rw;

grant insert on samqa.custom_eligibility_req_bkp to rl_sam_rw;

grant select on samqa.custom_eligibility_req_bkp to rl_sam1_ro;

grant select on samqa.custom_eligibility_req_bkp to rl_sam_rw;

grant select on samqa.custom_eligibility_req_bkp to rl_sam_ro;

grant update on samqa.custom_eligibility_req_bkp to rl_sam_rw;

