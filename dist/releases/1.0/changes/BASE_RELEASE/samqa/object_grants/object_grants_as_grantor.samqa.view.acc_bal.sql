-- liquibase formatted sql
-- changeset SAMQA:1754373942669 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_bal.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_bal.sql:null:c9b3fa6d8bc810225d9fa71eff8e58d271f0fc87:create

grant select on samqa.acc_bal to rl_sam1_ro;

grant select on samqa.acc_bal to rl_sam_rw;

grant select on samqa.acc_bal to rl_sam_ro;

grant select on samqa.acc_bal to sgali;

