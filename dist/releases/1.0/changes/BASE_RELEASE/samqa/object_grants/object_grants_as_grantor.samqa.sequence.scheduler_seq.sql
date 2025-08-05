-- liquibase formatted sql
-- changeset SAMQA:1754373938262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.scheduler_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.scheduler_seq.sql:null:25170e56dea531dc08b587a4512556e74710d81d:create

grant select on samqa.scheduler_seq to rl_sam_rw;

