-- liquibase formatted sql
-- changeset SAMQA:1754373942436 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.user_security_info.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.user_security_info.sql:null:4355e50ad577c490c6c773caa7d4dadfe33c17e3:create

grant delete on samqa.user_security_info to rl_sam_rw;

grant insert on samqa.user_security_info to rl_sam_rw;

grant select on samqa.user_security_info to rl_sam1_ro;

grant select on samqa.user_security_info to rl_sam_rw;

grant select on samqa.user_security_info to rl_sam_ro;

grant update on samqa.user_security_info to rl_sam_rw;

