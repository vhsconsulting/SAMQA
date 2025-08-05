-- liquibase formatted sql
-- changeset SAMQA:1754373944867 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.payroll_frequency.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.payroll_frequency.sql:null:22288616699bf5604394637fe706552ddbc65f14:create

grant select on samqa.payroll_frequency to rl_sam1_ro;

grant select on samqa.payroll_frequency to rl_sam_rw;

grant select on samqa.payroll_frequency to rl_sam_ro;

grant select on samqa.payroll_frequency to sgali;

