-- liquibase formatted sql
-- changeset SAMQA:1754373942785 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_vid.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_vid.sql:null:df4fa7471e078bac91b7827b1e7c76b36c2a0f85:create

grant select on samqa.account_vid to rl_sam1_ro;

grant select on samqa.account_vid to rl_sam_rw;

grant select on samqa.account_vid to rl_sam_ro;

grant select on samqa.account_vid to sgali;

