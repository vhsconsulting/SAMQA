-- liquibase formatted sql
-- changeset SAMQA:1754373943571 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ees_in_division_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ees_in_division_v.sql:null:455cb2e4a3cb872f106edc4c844a253609ee88d1:create

grant select on samqa.ees_in_division_v to rl_sam1_ro;

grant select on samqa.ees_in_division_v to rl_sam_rw;

grant select on samqa.ees_in_division_v to rl_sam_ro;

grant select on samqa.ees_in_division_v to sgali;

