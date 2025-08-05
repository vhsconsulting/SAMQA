-- liquibase formatted sql
-- changeset SAMQA:1754373942689 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_overview_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_overview_v.sql:null:3c77c3046abef51ebd5d609eb5228c85e6beaf18:create

grant select on samqa.acc_overview_v to rl_sam1_ro;

grant select on samqa.acc_overview_v to rl_sam_rw;

grant select on samqa.acc_overview_v to rl_sam_ro;

grant select on samqa.acc_overview_v to sgali;

