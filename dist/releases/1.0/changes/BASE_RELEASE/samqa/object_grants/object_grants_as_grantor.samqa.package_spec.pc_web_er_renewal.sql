-- liquibase formatted sql
-- changeset SAMQA:1754373936577 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_web_er_renewal.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_web_er_renewal.sql:null:6d5c2518ea95a52f40a6eadfbe7e0fa259ff8841:create

grant execute on samqa.pc_web_er_renewal to rl_temp_access_ro;

grant execute on samqa.pc_web_er_renewal to rl_sam_rw;

grant execute on samqa.pc_web_er_renewal to rl_sam_ro;

grant execute on samqa.pc_web_er_renewal to rl_sam1_ro;

grant debug on samqa.pc_web_er_renewal to rl_temp_access_ro;

grant debug on samqa.pc_web_er_renewal to sgali;

grant debug on samqa.pc_web_er_renewal to rl_sam_rw;

grant debug on samqa.pc_web_er_renewal to rl_sam1_ro;

grant debug on samqa.pc_web_er_renewal to rl_sam_ro;

