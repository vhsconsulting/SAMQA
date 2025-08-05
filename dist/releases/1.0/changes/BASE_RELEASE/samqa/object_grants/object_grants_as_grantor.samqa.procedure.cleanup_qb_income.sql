-- liquibase formatted sql
-- changeset SAMQA:1754373936725 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.cleanup_qb_income.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.cleanup_qb_income.sql:null:2b54fb1c6cdc414d5efe7ec95ebb1a2f1d10a548:create

grant execute on samqa.cleanup_qb_income to rl_sam_ro;

grant execute on samqa.cleanup_qb_income to rl_sam1_ro;

grant execute on samqa.cleanup_qb_income to rl_sam_rw;

grant debug on samqa.cleanup_qb_income to rl_sam1_ro;

grant debug on samqa.cleanup_qb_income to rl_sam_rw;

