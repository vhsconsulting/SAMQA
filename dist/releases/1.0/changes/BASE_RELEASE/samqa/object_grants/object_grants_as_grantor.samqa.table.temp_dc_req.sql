-- liquibase formatted sql
-- changeset SAMQA:1754373942285 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.temp_dc_req.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.temp_dc_req.sql:null:57e7639e721912a0522cc80d1fe9a842526239c6:create

grant delete on samqa.temp_dc_req to rl_sam_rw;

grant insert on samqa.temp_dc_req to rl_sam_rw;

grant select on samqa.temp_dc_req to rl_sam1_ro;

grant select on samqa.temp_dc_req to rl_sam_rw;

grant select on samqa.temp_dc_req to rl_sam_ro;

grant update on samqa.temp_dc_req to rl_sam_rw;

