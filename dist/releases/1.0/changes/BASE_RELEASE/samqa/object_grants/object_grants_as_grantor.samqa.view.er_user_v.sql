-- liquibase formatted sql
-- changeset SAMQA:1754373943858 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_user_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_user_v.sql:null:805b192344a9733e1a45c659351df17c663d2bbe:create

grant select on samqa.er_user_v to rl_sam1_ro;

grant select on samqa.er_user_v to rl_sam_rw;

grant select on samqa.er_user_v to rl_sam_ro;

grant select on samqa.er_user_v to sgali;

