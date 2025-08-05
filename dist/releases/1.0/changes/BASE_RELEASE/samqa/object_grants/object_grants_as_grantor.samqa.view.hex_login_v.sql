-- liquibase formatted sql
-- changeset SAMQA:1754373944229 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hex_login_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hex_login_v.sql:null:237c893bb05ee2efcf9f915d94825ec0730ef23a:create

grant select on samqa.hex_login_v to rl_sam1_ro;

grant select on samqa.hex_login_v to rl_sam_rw;

grant select on samqa.hex_login_v to rl_sam_ro;

grant select on samqa.hex_login_v to sgali;

