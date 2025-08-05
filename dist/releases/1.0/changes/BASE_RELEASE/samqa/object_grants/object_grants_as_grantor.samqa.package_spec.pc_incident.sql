-- liquibase formatted sql
-- changeset SAMQA:1754373936229 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.package_spec.pc_incident.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.package_spec.pc_incident.sql:null:54e0b20478baad77a6b6e550bd0c25ab8c383e74:create

grant execute on samqa.pc_incident to rl_sam_ro;

grant debug on samqa.pc_incident to rl_sam_ro;

