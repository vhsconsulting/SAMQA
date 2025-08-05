-- liquibase formatted sql
-- changeset SAMQA:1754373942817 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ach_nacha_v_old.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ach_nacha_v_old.sql:null:cac478248e9b19f3d2c5729e6a5940c33c4bd425:create

grant select on samqa.ach_nacha_v_old to rl_sam1_ro;

grant select on samqa.ach_nacha_v_old to rl_sam_rw;

grant select on samqa.ach_nacha_v_old to rl_sam_ro;

grant select on samqa.ach_nacha_v_old to sgali;

