-- liquibase formatted sql
-- changeset SAMQA:1754373944450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.insurance_category.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.insurance_category.sql:null:3b273730371612a27760f7c7ec0c2ed721ec5050:create

grant select on samqa.insurance_category to rl_sam1_ro;

grant select on samqa.insurance_category to rl_sam_rw;

grant select on samqa.insurance_category to rl_sam_ro;

grant select on samqa.insurance_category to sgali;

