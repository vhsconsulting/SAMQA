-- liquibase formatted sql
-- changeset SAMQA:1754373938555 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.agile_payment_access.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.agile_payment_access.sql:null:4b250f7e85df86668c406e40ce22057f91d46071:create

grant delete on samqa.agile_payment_access to rl_sam_rw;

grant insert on samqa.agile_payment_access to rl_sam_rw;

grant select on samqa.agile_payment_access to rl_sam1_ro;

grant select on samqa.agile_payment_access to rl_sam_ro;

grant select on samqa.agile_payment_access to rl_sam_rw;

grant update on samqa.agile_payment_access to rl_sam_rw;

