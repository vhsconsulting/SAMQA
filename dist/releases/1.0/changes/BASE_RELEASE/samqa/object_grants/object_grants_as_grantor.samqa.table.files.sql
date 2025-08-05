-- liquibase formatted sql
-- changeset SAMQA:1754373940511 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.files.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.files.sql:null:372b4964375be66ed2e32feeb51b6ffac0a59abb:create

grant delete on samqa.files to rl_sam_rw;

grant insert on samqa.files to rl_sam_rw;

grant select on samqa.files to rl_sam1_ro;

grant select on samqa.files to rl_sam_rw;

grant select on samqa.files to rl_sam_ro;

grant update on samqa.files to rl_sam_rw;

