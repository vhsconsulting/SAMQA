-- liquibase formatted sql
-- changeset SAMQA:1754373943531 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.deposit_audit_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.deposit_audit_v.sql:null:b6a878419d1e121d31269f549eb45d265f9021ca:create

grant select on samqa.deposit_audit_v to rl_sam1_ro;

grant select on samqa.deposit_audit_v to rl_sam_rw;

grant select on samqa.deposit_audit_v to rl_sam_ro;

grant select on samqa.deposit_audit_v to sgali;

