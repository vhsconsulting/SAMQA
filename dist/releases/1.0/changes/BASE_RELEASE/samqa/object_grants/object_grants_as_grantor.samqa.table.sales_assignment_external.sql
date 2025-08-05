-- liquibase formatted sql
-- changeset SAMQA:1754373941870 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.sales_assignment_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.sales_assignment_external.sql:null:a3b5bae987f8886ce2b95c2e1ca0355378346702:create

grant select on samqa.sales_assignment_external to rl_sam1_ro;

grant select on samqa.sales_assignment_external to rl_sam_ro;

