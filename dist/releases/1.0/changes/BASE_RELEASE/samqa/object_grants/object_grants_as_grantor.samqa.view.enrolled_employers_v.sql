-- liquibase formatted sql
-- changeset SAMQA:1754373943758 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.enrolled_employers_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.enrolled_employers_v.sql:null:e04095a23942cf1041e51b843029910b5a678ce6:create

grant select on samqa.enrolled_employers_v to rl_sam1_ro;

grant select on samqa.enrolled_employers_v to rl_sam_rw;

grant select on samqa.enrolled_employers_v to rl_sam_ro;

grant select on samqa.enrolled_employers_v to sgali;

