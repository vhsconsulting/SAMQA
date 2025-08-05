-- liquibase formatted sql
-- changeset SAMQA:1754373944711 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.new_catchup_65_age_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.new_catchup_65_age_v.sql:null:7d7f77f825ae734e2f251d1cf369c16927d25764:create

grant select on samqa.new_catchup_65_age_v to rl_sam1_ro;

grant select on samqa.new_catchup_65_age_v to rl_sam_rw;

grant select on samqa.new_catchup_65_age_v to rl_sam_ro;

grant select on samqa.new_catchup_65_age_v to sgali;

