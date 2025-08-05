-- liquibase formatted sql
-- changeset SAMQA:1754373936997 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.process_bps_deposits.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.process_bps_deposits.sql:null:bb2c6b67880be5321665f1f8c851f0faeda08389:create

grant execute on samqa.process_bps_deposits to rl_sam_ro;

grant execute on samqa.process_bps_deposits to rl_sam_rw;

grant execute on samqa.process_bps_deposits to rl_sam1_ro;

grant debug on samqa.process_bps_deposits to sgali;

grant debug on samqa.process_bps_deposits to rl_sam_rw;

grant debug on samqa.process_bps_deposits to rl_sam1_ro;

