-- liquibase formatted sql
-- changeset SAMQA:1754373943689 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employer_balances_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employer_balances_v.sql:null:bea280a1b14d25c3e69c40c04267313e6aa912b8:create

grant select on samqa.employer_balances_v to rl_sam1_ro;

grant select on samqa.employer_balances_v to rl_sam_rw;

grant select on samqa.employer_balances_v to rl_sam_ro;

grant select on samqa.employer_balances_v to sgali;

