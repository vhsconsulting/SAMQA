-- liquibase formatted sql
-- changeset SAMQA:1754373941460 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.online_renewals.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.online_renewals.sql:null:5cd48f939785b36ab5ccc4f0dad551f76334c714:create

grant delete on samqa.online_renewals to rl_sam_rw;

grant insert on samqa.online_renewals to rl_sam_rw;

grant select on samqa.online_renewals to rl_sam1_ro;

grant select on samqa.online_renewals to rl_sam_rw;

grant select on samqa.online_renewals to rl_sam_ro;

grant update on samqa.online_renewals to rl_sam_rw;

