-- liquibase formatted sql
-- changeset SAMQA:1754373940792 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.incident_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.incident_history.sql:null:a91aec1a342cc2f23cb39a52a7d114f5f2e36a47:create

grant delete on samqa.incident_history to rl_sam_rw;

grant insert on samqa.incident_history to rl_sam_rw;

grant select on samqa.incident_history to smareedu;

grant select on samqa.incident_history to rl_sam_ro;

