-- liquibase formatted sql
-- changeset SAMQA:1754373938525 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.activity_statement.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.activity_statement.sql:null:44fd5c7fd7e4ff754ec7b8ecaab6adfb4af2e8e3:create

grant delete on samqa.activity_statement to rl_sam_rw;

grant insert on samqa.activity_statement to rl_sam_rw;

grant select on samqa.activity_statement to rl_sam1_ro;

grant select on samqa.activity_statement to rl_sam_rw;

grant select on samqa.activity_statement to rl_sam_ro;

grant update on samqa.activity_statement to rl_sam_rw;

