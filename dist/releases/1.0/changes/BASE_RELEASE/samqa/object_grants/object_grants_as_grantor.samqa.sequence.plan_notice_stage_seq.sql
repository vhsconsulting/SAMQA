-- liquibase formatted sql
-- changeset SAMQA:1754373938134 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.plan_notice_stage_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.plan_notice_stage_seq.sql:null:2a73695ea59b33e6b3ff4c8186c15532604df6d4:create

grant select on samqa.plan_notice_stage_seq to rl_sam_rw;

