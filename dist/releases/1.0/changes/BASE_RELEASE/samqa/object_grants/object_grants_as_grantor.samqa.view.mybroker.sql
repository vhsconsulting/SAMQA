-- liquibase formatted sql
-- changeset SAMQA:1754373944593 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.mybroker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.mybroker.sql:null:3112e82f3752c1d5f4be89b9378d5fdba4aceb30:create

grant select on samqa.mybroker to rl_sam1_ro;

grant select on samqa.mybroker to rl_sam_rw;

grant select on samqa.mybroker to rl_sam_ro;

grant select on samqa.mybroker to sgali;

