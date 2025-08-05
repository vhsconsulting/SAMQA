-- liquibase formatted sql
-- changeset SAMQA:1754373940272 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_header_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_header_external.sql:null:57ec8d0cbd6ca42c5a66554f03585a696afb5c0e:create

grant select on samqa.eob_header_external to rl_sam1_ro;

grant select on samqa.eob_header_external to rl_sam_ro;

