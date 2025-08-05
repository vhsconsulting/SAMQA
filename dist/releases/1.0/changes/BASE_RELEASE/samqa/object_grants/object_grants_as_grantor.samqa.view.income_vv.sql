-- liquibase formatted sql
-- changeset SAMQA:1754373944418 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.income_vv.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.income_vv.sql:null:c59eda5a677fcfe09bee7d306e6e7ca1d9460067:create

grant select on samqa.income_vv to rl_sam1_ro;

grant select on samqa.income_vv to rl_sam_rw;

grant select on samqa.income_vv to rl_sam_ro;

grant select on samqa.income_vv to sgali;

