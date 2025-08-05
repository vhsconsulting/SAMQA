-- liquibase formatted sql
-- changeset SAMQA:1754373943940 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fraud_accounts_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fraud_accounts_v.sql:null:f00e87105481c3e3b1e569292a76e543692b651b:create

grant select on samqa.fraud_accounts_v to rl_sam1_ro;

grant select on samqa.fraud_accounts_v to rl_sam_rw;

grant select on samqa.fraud_accounts_v to rl_sam_ro;

grant select on samqa.fraud_accounts_v to sgali;

