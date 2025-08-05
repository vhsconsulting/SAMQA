-- liquibase formatted sql
-- changeset SAMQA:1754373942753 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_preference_ee_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_preference_ee_v.sql:null:1e4efb40e33f02dca5fa6eb25d26d32403f870bc:create

grant select on samqa.account_preference_ee_v to rl_sam1_ro;

grant select on samqa.account_preference_ee_v to rl_sam_rw;

grant select on samqa.account_preference_ee_v to rl_sam_ro;

grant select on samqa.account_preference_ee_v to sgali;

