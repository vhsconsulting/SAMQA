-- liquibase formatted sql
-- changeset SAMQA:1754373943882 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.external_1009_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.external_1009_v.sql:null:ef7e67c487e9aea67340950f56fd08b8ed2571de:create

grant select on samqa.external_1009_v to rl_sam1_ro;

grant select on samqa.external_1009_v to rl_sam_rw;

grant select on samqa.external_1009_v to rl_sam_ro;

grant select on samqa.external_1009_v to sgali;

