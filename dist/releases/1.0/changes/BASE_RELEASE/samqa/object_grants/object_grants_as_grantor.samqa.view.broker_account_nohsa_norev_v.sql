-- liquibase formatted sql
-- changeset SAMQA:1754373943055 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_account_nohsa_norev_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_account_nohsa_norev_v.sql:null:4a0ba5f86163b5ed6b6cb6bd366c2ecde20c561d:create

grant select on samqa.broker_account_nohsa_norev_v to rl_sam_ro;

grant read on samqa.broker_account_nohsa_norev_v to rl_sam_ro;

grant debug on samqa.broker_account_nohsa_norev_v to rl_sam_ro;

