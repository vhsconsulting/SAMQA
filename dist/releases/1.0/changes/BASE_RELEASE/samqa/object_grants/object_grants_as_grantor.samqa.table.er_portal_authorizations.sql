-- liquibase formatted sql
-- changeset SAMQA:1754373940321 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.er_portal_authorizations.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.er_portal_authorizations.sql:null:7a850f40974fcdabee710380a119d83547c1367c:create

grant delete on samqa.er_portal_authorizations to rl_sam_rw;

grant insert on samqa.er_portal_authorizations to rl_sam_rw;

grant select on samqa.er_portal_authorizations to rl_sam1_ro;

grant select on samqa.er_portal_authorizations to rl_sam_ro;

grant select on samqa.er_portal_authorizations to rl_sam_rw;

grant update on samqa.er_portal_authorizations to rl_sam_rw;

