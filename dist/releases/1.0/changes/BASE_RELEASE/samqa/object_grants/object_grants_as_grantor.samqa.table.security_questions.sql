-- liquibase formatted sql
-- changeset SAMQA:1754373942124 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.security_questions.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.security_questions.sql:null:41b970b2559566f9bea7643006863d074d9ed24f:create

grant delete on samqa.security_questions to rl_sam_rw;

grant insert on samqa.security_questions to rl_sam_rw;

grant select on samqa.security_questions to rl_sam1_ro;

grant select on samqa.security_questions to rl_sam_rw;

grant select on samqa.security_questions to rl_sam_ro;

grant update on samqa.security_questions to rl_sam_rw;

