-- liquibase formatted sql
-- changeset SAMQA:1754373938262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.scheduler_stage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.scheduler_stage_seq.sql:null:260802b561d36448c8b4cc7b3a3916bbeb51acff:create

grant select on samqa.scheduler_stage_seq to rl_sam_rw;

