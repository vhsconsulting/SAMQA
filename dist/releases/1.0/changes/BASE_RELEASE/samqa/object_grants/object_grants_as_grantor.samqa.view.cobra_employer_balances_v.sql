-- liquibase formatted sql
-- changeset SAMQA:1754373943390 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cobra_employer_balances_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cobra_employer_balances_v.sql:null:0dcaf98025bb549e1464e7e2536505d1a1ca3d21:create

grant select on samqa.cobra_employer_balances_v to rl_sam_ro;

grant select on samqa.cobra_employer_balances_v to rl_sam_rw;

grant select on samqa.cobra_employer_balances_v to rl_sam1_ro;

