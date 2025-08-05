-- liquibase formatted sql
-- changeset SAMQA:1754373943746 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.enroll_acc_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.enroll_acc_v.sql:null:cfc6d4366d870faef102ccac425a1192831d0deb:create

grant select on samqa.enroll_acc_v to rl_sam1_ro;

grant select on samqa.enroll_acc_v to rl_sam_rw;

grant select on samqa.enroll_acc_v to rl_sam_ro;

grant select on samqa.enroll_acc_v to sgali;

