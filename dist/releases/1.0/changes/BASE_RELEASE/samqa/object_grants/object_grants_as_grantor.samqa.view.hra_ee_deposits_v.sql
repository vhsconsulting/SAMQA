-- liquibase formatted sql
-- changeset SAMQA:1754373944243 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_ee_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_ee_deposits_v.sql:null:6248940b13dbf2e5e38da1815f16201068e607f1:create

grant select on samqa.hra_ee_deposits_v to rl_sam1_ro;

grant select on samqa.hra_ee_deposits_v to rl_sam_rw;

grant select on samqa.hra_ee_deposits_v to rl_sam_ro;

grant select on samqa.hra_ee_deposits_v to sgali;

