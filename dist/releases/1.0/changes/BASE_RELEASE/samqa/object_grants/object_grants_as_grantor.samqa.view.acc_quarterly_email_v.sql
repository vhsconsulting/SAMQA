-- liquibase formatted sql
-- changeset SAMQA:1754373942708 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_quarterly_email_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_quarterly_email_v.sql:null:e63b376abc1d8927387ae4c60e91da1725e3af5a:create

grant select on samqa.acc_quarterly_email_v to rl_sam1_ro;

grant select on samqa.acc_quarterly_email_v to rl_sam_rw;

grant select on samqa.acc_quarterly_email_v to rl_sam_ro;

grant select on samqa.acc_quarterly_email_v to sgali;

