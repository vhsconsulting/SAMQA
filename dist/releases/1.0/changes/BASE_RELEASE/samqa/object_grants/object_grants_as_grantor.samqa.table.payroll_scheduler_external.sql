-- liquibase formatted sql
-- changeset SAMQA:1754373941642 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.payroll_scheduler_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.payroll_scheduler_external.sql:null:88bd7e03c2b59d740f1731d8cc1fee89463ec956:create

grant select on samqa.payroll_scheduler_external to rl_sam1_ro;

grant select on samqa.payroll_scheduler_external to rl_sam_ro;

