-- liquibase formatted sql
-- changeset SAMQA:1754373945041 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.relative.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.relative.sql:null:452d2dac72e741e245397e569a452912b3a7fbfd:create

grant select on samqa.relative to rl_sam1_ro;

grant select on samqa.relative to rl_sam_rw;

grant select on samqa.relative to rl_sam_ro;

grant select on samqa.relative to sgali;

