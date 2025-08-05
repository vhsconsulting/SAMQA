-- liquibase formatted sql
-- changeset SAMQA:1754373940266 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_header.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_header.sql:null:11c71cff1e02be6ddbe9f26d05da6126faafe888:create

grant delete on samqa.eob_header to rl_sam_rw;

grant insert on samqa.eob_header to rl_sam_rw;

grant select on samqa.eob_header to rl_sam1_ro;

grant select on samqa.eob_header to rl_sam_rw;

grant select on samqa.eob_header to rl_sam_ro;

grant update on samqa.eob_header to rl_sam_rw;

