-- liquibase formatted sql
-- changeset SAMQA:1754373942943 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.bal_rate.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.bal_rate.sql:null:925523fd0d30f0882f486d6ce0059c26d0047d54:create

grant select on samqa.bal_rate to rl_sam1_ro;

grant select on samqa.bal_rate to rl_sam_rw;

grant select on samqa.bal_rate to rl_sam_ro;

grant select on samqa.bal_rate to sgali;

