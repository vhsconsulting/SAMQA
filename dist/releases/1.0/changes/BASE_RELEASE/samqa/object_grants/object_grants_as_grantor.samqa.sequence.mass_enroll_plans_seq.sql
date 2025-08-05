-- liquibase formatted sql
-- changeset SAMQA:1754373937954 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.mass_enroll_plans_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.mass_enroll_plans_seq.sql:null:41cee207dd7c8d2f70216430cf548d0309b607f2:create

grant select on samqa.mass_enroll_plans_seq to rl_sam_rw;

