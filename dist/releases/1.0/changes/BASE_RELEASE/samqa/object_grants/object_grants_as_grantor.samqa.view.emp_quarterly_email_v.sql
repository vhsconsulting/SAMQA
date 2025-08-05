-- liquibase formatted sql
-- changeset SAMQA:1754373943643 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.emp_quarterly_email_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.emp_quarterly_email_v.sql:null:a75d55b776a0c89cd00cd9648d4de78d7f579c4b:create

grant select on samqa.emp_quarterly_email_v to rl_sam1_ro;

grant select on samqa.emp_quarterly_email_v to rl_sam_rw;

grant select on samqa.emp_quarterly_email_v to rl_sam_ro;

grant select on samqa.emp_quarterly_email_v to sgali;

