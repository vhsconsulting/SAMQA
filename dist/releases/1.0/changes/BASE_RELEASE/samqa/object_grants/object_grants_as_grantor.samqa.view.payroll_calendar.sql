-- liquibase formatted sql
-- changeset SAMQA:1754373944867 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.payroll_calendar.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.payroll_calendar.sql:null:56c6c3cfaefb89bf5192199a3406bcb3537070c9:create

grant select on samqa.payroll_calendar to rl_sam1_ro;

grant select on samqa.payroll_calendar to rl_sam_rw;

grant select on samqa.payroll_calendar to rl_sam_ro;

grant select on samqa.payroll_calendar to sgali;

