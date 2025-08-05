-- liquibase formatted sql
-- changeset SAMQA:1754373945078 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.sam_login_summary_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.sam_login_summary_v.sql:null:53e0003bd8199d5aebfbbab576d682a140cd666a:create

grant select on samqa.sam_login_summary_v to rl_sam1_ro;

grant select on samqa.sam_login_summary_v to rl_sam_rw;

grant select on samqa.sam_login_summary_v to rl_sam_ro;

