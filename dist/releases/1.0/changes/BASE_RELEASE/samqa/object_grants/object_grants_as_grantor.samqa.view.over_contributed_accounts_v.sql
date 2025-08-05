-- liquibase formatted sql
-- changeset SAMQA:1754373944787 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.over_contributed_accounts_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.over_contributed_accounts_v.sql:null:991ec408d7019744aecf726869b1841e1ff9a3ff:create

grant select on samqa.over_contributed_accounts_v to rl_sam1_ro;

grant select on samqa.over_contributed_accounts_v to rl_sam_rw;

grant select on samqa.over_contributed_accounts_v to rl_sam_ro;

grant select on samqa.over_contributed_accounts_v to sgali;

