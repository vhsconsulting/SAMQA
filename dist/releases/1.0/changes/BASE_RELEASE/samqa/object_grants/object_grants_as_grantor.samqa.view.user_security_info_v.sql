-- liquibase formatted sql
-- changeset SAMQA:1754373945418 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.user_security_info_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.user_security_info_v.sql:null:0e02b41b23bcb62b60421267b7c3c6ff58f16d0d:create

grant select on samqa.user_security_info_v to rl_sam_rw;

grant select on samqa.user_security_info_v to rl_sam_ro;

grant select on samqa.user_security_info_v to sgali;

grant select on samqa.user_security_info_v to rl_sam1_ro;

