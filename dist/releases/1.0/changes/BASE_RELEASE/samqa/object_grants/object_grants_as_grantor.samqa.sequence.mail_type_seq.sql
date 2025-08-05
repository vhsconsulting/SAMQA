-- liquibase formatted sql
-- changeset SAMQA:1754373937932 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.mail_type_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.mail_type_seq.sql:null:c67591291666901deb815748c9290c8045f4a9d5:create

grant select on samqa.mail_type_seq to rl_sam_rw;

