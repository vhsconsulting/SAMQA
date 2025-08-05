-- liquibase formatted sql
-- changeset SAMQA:1754373944731 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.new_catchup_accounts_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.new_catchup_accounts_v.sql:null:e439432ad33079960d991206c4cd4010b5e99b63:create

grant select on samqa.new_catchup_accounts_v to rl_sam1_ro;

grant select on samqa.new_catchup_accounts_v to rl_sam_rw;

grant select on samqa.new_catchup_accounts_v to rl_sam_ro;

grant select on samqa.new_catchup_accounts_v to sgali;

