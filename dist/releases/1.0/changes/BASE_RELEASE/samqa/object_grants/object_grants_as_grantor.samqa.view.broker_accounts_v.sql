-- liquibase formatted sql
-- changeset SAMQA:1754373943055 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.broker_accounts_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.broker_accounts_v.sql:null:5b0af3b52d9a1840e4d42784c1ccc6380c01eb1a:create

grant select on samqa.broker_accounts_v to rl_sam_ro;

grant read on samqa.broker_accounts_v to rl_sam_ro;

grant on commit refresh on samqa.broker_accounts_v to rl_sam_ro;

grant query rewrite on samqa.broker_accounts_v to rl_sam_ro;

grant debug on samqa.broker_accounts_v to rl_sam_ro;

