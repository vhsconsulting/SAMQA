-- liquibase formatted sql
-- changeset SAMQA:1754373937376 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ben_plan_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ben_plan_seq.sql:null:6b3a60d8976231a7f7509ecf952297ddfd2709d9:create

grant select on samqa.ben_plan_seq to rl_sam_rw;

