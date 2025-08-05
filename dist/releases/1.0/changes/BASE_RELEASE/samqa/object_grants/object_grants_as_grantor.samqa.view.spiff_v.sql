-- liquibase formatted sql
-- changeset SAMQA:1754373945122 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.spiff_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.spiff_v.sql:null:18ef56662f9a299bcd282f5c6749cf0c803d6ca8:create

grant select on samqa.spiff_v to rl_sam1_ro;

grant select on samqa.spiff_v to rl_sam_rw;

grant select on samqa.spiff_v to rl_sam_ro;

grant select on samqa.spiff_v to sgali;

