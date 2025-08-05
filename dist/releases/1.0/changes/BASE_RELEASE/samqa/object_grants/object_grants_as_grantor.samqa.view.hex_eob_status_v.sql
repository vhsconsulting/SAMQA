-- liquibase formatted sql
-- changeset SAMQA:1754373944223 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hex_eob_status_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hex_eob_status_v.sql:null:32a20df1a649c214018552fce8eec861d8deeed3:create

grant select on samqa.hex_eob_status_v to rl_sam1_ro;

grant select on samqa.hex_eob_status_v to rl_sam_rw;

grant select on samqa.hex_eob_status_v to rl_sam_ro;

grant select on samqa.hex_eob_status_v to sgali;

