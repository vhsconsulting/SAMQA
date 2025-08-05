-- liquibase formatted sql
-- changeset SAMQA:1754373942815 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ach_emp_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ach_emp_detail_v.sql:null:75bcac463e9f690b14c722d85200b8cf352ecbec:create

grant select on samqa.ach_emp_detail_v to rl_sam1_ro;

grant select on samqa.ach_emp_detail_v to rl_sam_rw;

grant select on samqa.ach_emp_detail_v to rl_sam_ro;

grant select on samqa.ach_emp_detail_v to sgali;

