-- liquibase formatted sql
-- changeset SAMQA:1754373938134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.plan_notice_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.plan_notice_seq.sql:null:85c2035bec20c352c303580c3eb7a5fc93003dad:create

grant select on samqa.plan_notice_seq to rl_sam_rw;

