-- liquibase formatted sql
-- changeset SAMQA:1754373935088 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.add_bus_days.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.add_bus_days.sql:null:0e7692d93197f83b22d77a3a51caa72a9f26ed9a:create

grant execute on samqa.add_bus_days to rl_sam_ro;

