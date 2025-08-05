-- liquibase formatted sql
-- changeset SAMQA:1754373941629 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.payroll_calendar_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.payroll_calendar_bkp.sql:null:ebf1de582d15fee773cc9dcd46d0841a9556f2bc:create

grant delete on samqa.payroll_calendar_bkp to rl_sam_rw;

grant insert on samqa.payroll_calendar_bkp to rl_sam_rw;

grant select on samqa.payroll_calendar_bkp to rl_sam1_ro;

grant select on samqa.payroll_calendar_bkp to rl_sam_rw;

grant select on samqa.payroll_calendar_bkp to rl_sam_ro;

grant update on samqa.payroll_calendar_bkp to rl_sam_rw;

