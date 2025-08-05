-- liquibase formatted sql
-- changeset SAMQA:1754373936731 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.close_qb_account.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.close_qb_account.sql:null:09803235cde4eaca73b81c646d5e8721b7558516:create

grant execute on samqa.close_qb_account to rl_sam_ro;

grant execute on samqa.close_qb_account to rl_sam_rw;

grant execute on samqa.close_qb_account to rl_sam1_ro;

grant debug on samqa.close_qb_account to rl_sam_rw;

grant debug on samqa.close_qb_account to rl_sam1_ro;

