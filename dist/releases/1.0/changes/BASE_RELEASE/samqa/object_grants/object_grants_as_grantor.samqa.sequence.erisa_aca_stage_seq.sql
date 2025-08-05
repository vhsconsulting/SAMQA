-- liquibase formatted sql
-- changeset SAMQA:1754373937753 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.erisa_aca_stage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.erisa_aca_stage_seq.sql:null:bcccfc0e77ddd766e3b26386e480064f2be13b47:create

grant select on samqa.erisa_aca_stage_seq to rl_sam_rw;

