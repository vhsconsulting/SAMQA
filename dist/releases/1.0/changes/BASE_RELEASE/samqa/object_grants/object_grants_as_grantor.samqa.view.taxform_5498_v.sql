-- liquibase formatted sql
-- changeset SAMQA:1754373945262 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.taxform_5498_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.taxform_5498_v.sql:null:e477626941faeb0ad364330ac750ddcc4829fcd7:create

grant select on samqa.taxform_5498_v to rl_sam_rw;

grant select on samqa.taxform_5498_v to rl_sam_ro;

grant select on samqa.taxform_5498_v to sgali;

grant select on samqa.taxform_5498_v to rl_sam1_ro;

