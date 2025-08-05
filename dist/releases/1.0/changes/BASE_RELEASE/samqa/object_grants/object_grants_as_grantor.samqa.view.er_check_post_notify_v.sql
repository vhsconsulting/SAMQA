-- liquibase formatted sql
-- changeset SAMQA:1754373943821 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.er_check_post_notify_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.er_check_post_notify_v.sql:null:ad4a85772cbf28c38ce7065858b44101a021b217:create

grant select on samqa.er_check_post_notify_v to rl_sam1_ro;

grant select on samqa.er_check_post_notify_v to rl_sam_rw;

grant select on samqa.er_check_post_notify_v to rl_sam_ro;

grant select on samqa.er_check_post_notify_v to sgali;

