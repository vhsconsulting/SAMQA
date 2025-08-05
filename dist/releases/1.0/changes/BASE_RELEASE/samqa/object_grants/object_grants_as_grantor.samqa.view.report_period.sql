-- liquibase formatted sql
-- changeset SAMQA:1754373945052 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.report_period.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.report_period.sql:null:224abbef929879f1f9a3770e8e17c5fce3df0286:create

grant select on samqa.report_period to rl_sam1_ro;

grant select on samqa.report_period to rl_sam_rw;

grant select on samqa.report_period to rl_sam_ro;

grant select on samqa.report_period to sgali;

