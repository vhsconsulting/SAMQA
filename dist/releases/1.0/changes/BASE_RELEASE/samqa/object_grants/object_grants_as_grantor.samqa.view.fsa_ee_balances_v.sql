-- liquibase formatted sql
-- changeset SAMQA:1754373943972 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_ee_balances_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_ee_balances_v.sql:null:7e8fea656fd1eb56200bca7dac5eb75d8848ca18:create

grant select on samqa.fsa_ee_balances_v to rl_sam1_ro;

grant select on samqa.fsa_ee_balances_v to rl_sam_rw;

grant select on samqa.fsa_ee_balances_v to rl_sam_ro;

grant select on samqa.fsa_ee_balances_v to sgali;

