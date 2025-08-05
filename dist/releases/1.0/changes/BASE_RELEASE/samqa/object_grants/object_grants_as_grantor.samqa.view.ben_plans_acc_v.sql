-- liquibase formatted sql
-- changeset SAMQA:1754373942996 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ben_plans_acc_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ben_plans_acc_v.sql:null:1cf17e2360459209a13522d0f7eb0e5f2f411972:create

grant select on samqa.ben_plans_acc_v to rl_sam1_ro;

grant select on samqa.ben_plans_acc_v to rl_sam_rw;

grant select on samqa.ben_plans_acc_v to rl_sam_ro;

grant select on samqa.ben_plans_acc_v to sgali;

