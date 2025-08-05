-- liquibase formatted sql
-- changeset SAMQA:1754373943023 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.biweekly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.biweekly_v.sql:null:e9a68d4e24667f8b944c798cfada86fb5ac0f293:create

grant select on samqa.biweekly_v to rl_sam1_ro;

grant select on samqa.biweekly_v to rl_sam_rw;

grant select on samqa.biweekly_v to rl_sam_ro;

grant select on samqa.biweekly_v to sgali;

