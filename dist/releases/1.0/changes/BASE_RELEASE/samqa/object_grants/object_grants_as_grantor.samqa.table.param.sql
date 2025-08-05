-- liquibase formatted sql
-- changeset SAMQA:1754373941536 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.param.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.param.sql:null:d33daacdd49c07df9dd308b774dc83ae96a0d627:create

grant delete on samqa.param to rl_sam_rw;

grant insert on samqa.param to rl_sam_rw;

grant select on samqa.param to rl_sam1_ro;

grant select on samqa.param to rl_sam_rw;

grant select on samqa.param to rl_sam_ro;

grant update on samqa.param to rl_sam_rw;

