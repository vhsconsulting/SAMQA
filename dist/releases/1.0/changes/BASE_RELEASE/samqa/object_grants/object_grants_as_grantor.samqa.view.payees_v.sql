-- liquibase formatted sql
-- changeset SAMQA:1754373944826 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.payees_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.payees_v.sql:null:34fa6c1f57e6a609fac6c50c147c4fb54ddafb97:create

grant select on samqa.payees_v to rl_sam1_ro;

grant select on samqa.payees_v to rl_sam_rw;

grant select on samqa.payees_v to rl_sam_ro;

grant select on samqa.payees_v to sgali;

