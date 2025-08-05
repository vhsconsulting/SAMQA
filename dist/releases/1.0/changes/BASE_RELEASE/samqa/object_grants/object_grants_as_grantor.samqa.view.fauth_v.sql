-- liquibase formatted sql
-- changeset SAMQA:1754373943906 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fauth_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fauth_v.sql:null:8b4f3f745ed313b68adf734daad2fc85268df7de:create

grant select on samqa.fauth_v to rl_sam1_ro;

grant select on samqa.fauth_v to rl_sam_rw;

grant select on samqa.fauth_v to rl_sam_ro;

grant select on samqa.fauth_v to sgali;

