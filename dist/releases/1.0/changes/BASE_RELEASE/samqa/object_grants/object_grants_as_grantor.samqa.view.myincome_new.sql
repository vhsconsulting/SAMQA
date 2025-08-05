-- liquibase formatted sql
-- changeset SAMQA:1754373944643 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.myincome_new.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.myincome_new.sql:null:3641b78690201e8c307bf29621796934e8b9d7dd:create

grant select on samqa.myincome_new to rl_sam1_ro;

grant select on samqa.myincome_new to rl_sam_rw;

grant select on samqa.myincome_new to rl_sam_ro;

grant select on samqa.myincome_new to sgali;

