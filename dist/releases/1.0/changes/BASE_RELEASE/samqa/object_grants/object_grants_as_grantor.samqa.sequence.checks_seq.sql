-- liquibase formatted sql
-- changeset SAMQA:1754373937460 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.checks_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.checks_seq.sql:null:fddc63bdf123999aa714a11832da678b3d454c2b:create

grant select on samqa.checks_seq to rl_sam_rw;

