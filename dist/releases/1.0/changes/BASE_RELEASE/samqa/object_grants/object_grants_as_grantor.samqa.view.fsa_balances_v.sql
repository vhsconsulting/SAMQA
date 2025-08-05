-- liquibase formatted sql
-- changeset SAMQA:1754373943946 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_balances_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_balances_v.sql:null:d7007a66a5ffb180d9cbc5f7860556bfab23dc57:create

grant select on samqa.fsa_balances_v to rl_sam1_ro;

grant select on samqa.fsa_balances_v to rl_sam_rw;

grant select on samqa.fsa_balances_v to rl_sam_ro;

grant select on samqa.fsa_balances_v to sgali;

