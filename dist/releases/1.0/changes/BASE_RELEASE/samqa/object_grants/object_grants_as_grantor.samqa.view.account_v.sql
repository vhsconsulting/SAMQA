-- liquibase formatted sql
-- changeset SAMQA:1754373942769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_v.sql:null:7cb2b9a1081c97b786f59d969587875b2a8d5915:create

grant select on samqa.account_v to rl_sam1_ro;

grant select on samqa.account_v to rl_sam_rw;

grant select on samqa.account_v to rl_sam_ro;

grant select on samqa.account_v to sgali;

