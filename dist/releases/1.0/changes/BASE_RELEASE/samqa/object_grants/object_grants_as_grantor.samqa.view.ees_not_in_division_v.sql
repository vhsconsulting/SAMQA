-- liquibase formatted sql
-- changeset SAMQA:1754373943578 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ees_not_in_division_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ees_not_in_division_v.sql:null:469bc416f4b2df1e45a36b93e75029737afc26d8:create

grant select on samqa.ees_not_in_division_v to rl_sam1_ro;

grant select on samqa.ees_not_in_division_v to rl_sam_rw;

grant select on samqa.ees_not_in_division_v to rl_sam_ro;

grant select on samqa.ees_not_in_division_v to sgali;

