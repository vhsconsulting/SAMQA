-- liquibase formatted sql
-- changeset SAMQA:1754373942721 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_status_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_status_v.sql:null:09b96fce3d8019466626507da64e63f34a918b58:create

grant select on samqa.acc_status_v to rl_sam1_ro;

grant select on samqa.acc_status_v to rl_sam_rw;

grant select on samqa.acc_status_v to rl_sam_ro;

grant select on samqa.acc_status_v to sgali;

