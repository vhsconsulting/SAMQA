-- liquibase formatted sql
-- changeset SAMQA:1754373943900 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.external_5498_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.external_5498_v.sql:null:52338d51b25b034b3e5840dea4be37c105974fc7:create

grant select on samqa.external_5498_v to rl_sam1_ro;

grant select on samqa.external_5498_v to rl_sam_rw;

grant select on samqa.external_5498_v to rl_sam_ro;

grant select on samqa.external_5498_v to sgali;

