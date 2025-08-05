-- liquibase formatted sql
-- changeset SAMQA:1754373940769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.incident_detail_notes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.incident_detail_notes.sql:null:c273dfafac4d3ab4f3ce34af9579ba7ce77441cc:create

grant delete on samqa.incident_detail_notes to rl_sam_rw;

grant insert on samqa.incident_detail_notes to rl_sam_rw;

grant select on samqa.incident_detail_notes to smareedu;

grant select on samqa.incident_detail_notes to rl_sam_ro;

