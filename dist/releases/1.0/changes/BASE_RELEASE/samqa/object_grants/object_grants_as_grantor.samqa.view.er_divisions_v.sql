-- liquibase formatted sql
-- changeset SAMQA:1754373943827 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_divisions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_divisions_v.sql:null:51829de52ba81cb41e7ca3f4c3c237ba0918fe84:create

grant select on samqa.er_divisions_v to rl_sam1_ro;

grant select on samqa.er_divisions_v to rl_sam_rw;

grant select on samqa.er_divisions_v to rl_sam_ro;

grant select on samqa.er_divisions_v to sgali;

