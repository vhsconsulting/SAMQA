-- liquibase formatted sql
-- changeset SAMQA:1754373942532 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.website_logs.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.website_logs.sql:null:6a146937b4d18d89fead51cdd6d6885d70009597:create

grant delete on samqa.website_logs to rl_sam_rw;

grant insert on samqa.website_logs to rl_sam_rw;

grant select on samqa.website_logs to rl_sam1_ro;

grant select on samqa.website_logs to rl_sam_rw;

grant select on samqa.website_logs to rl_sam_ro;

grant update on samqa.website_logs to rl_sam_rw;

