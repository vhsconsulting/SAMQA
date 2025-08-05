-- liquibase formatted sql
-- changeset SAMQA:1754373943039 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_account_hsa_norev_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_account_hsa_norev_v.sql:null:7371ca390c9eb0e6ec296b609b9311a781579458:create

grant select on samqa.broker_account_hsa_norev_v to rl_sam_ro;

grant read on samqa.broker_account_hsa_norev_v to rl_sam_ro;

grant debug on samqa.broker_account_hsa_norev_v to rl_sam_ro;

