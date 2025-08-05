-- liquibase formatted sql
-- changeset SAMQA:1754373942895 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.agt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.agt_v.sql:null:12af5e0620433f6f3a429be16637dd30b8123ccf:create

grant select on samqa.agt_v to rl_sam1_ro;

grant select on samqa.agt_v to rl_sam_rw;

grant select on samqa.agt_v to rl_sam_ro;

grant select on samqa.agt_v to sgali;

