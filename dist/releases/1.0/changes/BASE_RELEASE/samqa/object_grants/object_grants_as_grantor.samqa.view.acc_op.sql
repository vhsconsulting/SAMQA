-- liquibase formatted sql
-- changeset SAMQA:1754373942682 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_op.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_op.sql:null:750eeaaf58e660b285e7b7e30208b877396bfb99:create

grant select on samqa.acc_op to rl_sam1_ro;

grant select on samqa.acc_op to rl_sam_rw;

grant select on samqa.acc_op to rl_sam_ro;

grant select on samqa.acc_op to sgali;

