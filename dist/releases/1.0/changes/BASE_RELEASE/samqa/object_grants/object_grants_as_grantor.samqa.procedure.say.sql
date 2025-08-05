-- liquibase formatted sql
-- changeset SAMQA:1754373937171 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.procedure.say.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.procedure.say.sql:null:0d0051f5d4504541509eab15445ce7000da85479:create

grant execute on samqa.say to rl_sam_ro;

grant execute on samqa.say to rl_sam_rw;

grant execute on samqa.say to rl_sam1_ro;

grant debug on samqa.say to sgali;

grant debug on samqa.say to rl_sam_rw;

grant debug on samqa.say to rl_sam1_ro;

