-- liquibase formatted sql
-- changeset SAMQA:1754373940293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.eob_status_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.eob_status_external.sql:null:c4d49488f631f78978cf06e28addfb8225308b23:create

grant select on samqa.eob_status_external to rl_sam1_ro;

grant select on samqa.eob_status_external to rl_sam_ro;

