-- liquibase formatted sql
-- changeset SAMQA:1754373938166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.rate_plan_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.rate_plan_detail_seq.sql:null:4dd542f0cc10dba42b4f410cb5c3ec4cfa564619:create

grant select on samqa.rate_plan_detail_seq to rl_sam_rw;

