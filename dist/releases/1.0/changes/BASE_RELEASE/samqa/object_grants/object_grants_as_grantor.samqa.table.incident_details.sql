-- liquibase formatted sql
-- changeset SAMQA:1754373940792 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.incident_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.incident_details.sql:null:8e9bf6cc445501bd30ccc48c7c35d4d6a8b3dc4e:create

grant delete on samqa.incident_details to rl_sam_rw;

grant insert on samqa.incident_details to rl_sam_rw;

grant insert on samqa.incident_details to smareedu;

grant select on samqa.incident_details to rl_sam_rw;

grant select on samqa.incident_details to smareedu;

grant select on samqa.incident_details to rl_sam_ro;

