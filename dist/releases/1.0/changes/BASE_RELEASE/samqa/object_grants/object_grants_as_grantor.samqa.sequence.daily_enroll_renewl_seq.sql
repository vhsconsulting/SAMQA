-- liquibase formatted sql
-- changeset SAMQA:1754373937573 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.daily_enroll_renewl_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.daily_enroll_renewl_seq.sql:null:18c58bddb3ef467e103709223d5e3a7a57c95aed:create

grant select on samqa.daily_enroll_renewl_seq to rl_sam_rw;

