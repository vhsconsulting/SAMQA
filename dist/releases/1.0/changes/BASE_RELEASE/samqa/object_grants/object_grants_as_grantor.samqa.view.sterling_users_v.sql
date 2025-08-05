-- liquibase formatted sql
-- changeset SAMQA:1754373945138 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.sterling_users_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.sterling_users_v.sql:null:010e80b736d028ff3082e62a2d259fb44b14ca01:create

grant select on samqa.sterling_users_v to rl_sam_rw;

grant select on samqa.sterling_users_v to rl_sam_ro;

grant select on samqa.sterling_users_v to sgali;

grant select on samqa.sterling_users_v to rl_sam1_ro;

