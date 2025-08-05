-- liquibase formatted sql
-- changeset SAMQA:1754373942539 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.website_logs_temp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.website_logs_temp.sql:null:96e6ae98c5e3d1d9de50c09550ca32f8d2ffb9da:create

grant delete on samqa.website_logs_temp to rl_sam_rw;

grant insert on samqa.website_logs_temp to rl_sam_rw;

grant select on samqa.website_logs_temp to rl_sam1_ro;

grant select on samqa.website_logs_temp to rl_sam_rw;

grant select on samqa.website_logs_temp to rl_sam_ro;

grant update on samqa.website_logs_temp to rl_sam_rw;

