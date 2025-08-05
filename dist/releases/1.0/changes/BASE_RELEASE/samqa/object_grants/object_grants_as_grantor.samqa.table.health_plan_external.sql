-- liquibase formatted sql
-- changeset SAMQA:1754373940687 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.health_plan_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.health_plan_external.sql:null:22750ec33ea0ce6123886eed92584b82594c54f7:create

grant select on samqa.health_plan_external to rl_sam_ro;

