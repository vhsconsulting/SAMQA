-- liquibase formatted sql
-- changeset SAMQA:1754373938448 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ach_emp_detail_ext.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ach_emp_detail_ext.sql:null:f6490a30ee9518a468d0923b7fbe28996b720497:create

grant select on samqa.ach_emp_detail_ext to rl_sam1_ro;

grant select on samqa.ach_emp_detail_ext to rl_sam_ro;

