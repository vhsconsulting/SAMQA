-- liquibase formatted sql
-- changeset SAMQA:1754373944967 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.plb_users_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.plb_users_v.sql:null:1e5e90b7f13a274d872d9a567145a78346a4edde:create

grant select on samqa.plb_users_v to rl_sam1_ro;

grant select on samqa.plb_users_v to rl_sam_rw;

grant select on samqa.plb_users_v to rl_sam_ro;

grant select on samqa.plb_users_v to sgali;

