-- liquibase formatted sql
-- changeset SAMQA:1754373941877 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_assignment_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_assignment_staging.sql:null:09869d6e569e6c2c91c186738a256b60763d4b43:create

grant delete on samqa.sales_assignment_staging to rl_sam_rw;

grant insert on samqa.sales_assignment_staging to rl_sam_rw;

grant select on samqa.sales_assignment_staging to rl_sam1_ro;

grant select on samqa.sales_assignment_staging to rl_sam_rw;

grant select on samqa.sales_assignment_staging to rl_sam_ro;

grant update on samqa.sales_assignment_staging to rl_sam_rw;

