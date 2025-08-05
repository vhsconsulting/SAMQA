-- liquibase formatted sql
-- changeset SAMQA:1754373942676 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.acc_contributions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.acc_contributions_v.sql:null:53cce24626c95beab33ce8b6e6288717723dda09:create

grant select on samqa.acc_contributions_v to rl_sam1_ro;

grant select on samqa.acc_contributions_v to rl_sam_rw;

grant select on samqa.acc_contributions_v to rl_sam_ro;

grant select on samqa.acc_contributions_v to sgali;

