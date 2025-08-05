-- liquibase formatted sql
-- changeset SAMQA:1754373936283 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_log.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_log.sql:null:3c61dfe42f9ad7dc09c31493ddb17cf4d73a91b7:create

grant execute on samqa.pc_log to rl_sam_ro;

grant execute on samqa.pc_log to rl_sam_rw;

grant execute on samqa.pc_log to cobra;

grant execute on samqa.pc_log to rl_sam1_ro;

grant debug on samqa.pc_log to sgali;

grant debug on samqa.pc_log to rl_sam_rw;

grant debug on samqa.pc_log to rl_sam1_ro;

grant debug on samqa.pc_log to rl_sam_ro;

