-- liquibase formatted sql
-- changeset SAMQA:1754373940235 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_detail_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_detail_external.sql:null:a9a21caedaf0992b64caade5d3af5175389a0113:create

grant select on samqa.eob_detail_external to rl_sam1_ro;

grant select on samqa.eob_detail_external to rl_sam_ro;

