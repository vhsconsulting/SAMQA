-- liquibase formatted sql
-- changeset SAMQA:1754373944411 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.income_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.income_v.sql:null:d4078152a8c8e89a6f49a64aa8f3c4768d1fbd71:create

grant select on samqa.income_v to rl_sam1_ro;

grant select on samqa.income_v to rl_sam_rw;

grant select on samqa.income_v to rl_sam_ro;

grant select on samqa.income_v to sgali;

