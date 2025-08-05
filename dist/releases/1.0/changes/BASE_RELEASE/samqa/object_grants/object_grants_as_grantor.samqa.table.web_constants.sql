-- liquibase formatted sql
-- changeset SAMQA:1754373942503 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.web_constants.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.web_constants.sql:null:a39fd59e6f9b3c1b1efb8c7847231d71c5dd187f:create

grant delete on samqa.web_constants to rl_sam_rw;

grant insert on samqa.web_constants to rl_sam_rw;

grant select on samqa.web_constants to rl_sam1_ro;

grant select on samqa.web_constants to rl_sam_rw;

grant select on samqa.web_constants to rl_sam_ro;

grant update on samqa.web_constants to rl_sam_rw;

