-- liquibase formatted sql
-- changeset SAMQA:1754373942807 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ach_ee_terminated_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ach_ee_terminated_v.sql:null:4554d6fe90b30abc1de27f950a44eaa7533c9ffa:create

grant select on samqa.ach_ee_terminated_v to rl_sam1_ro;

grant select on samqa.ach_ee_terminated_v to rl_sam_rw;

grant select on samqa.ach_ee_terminated_v to rl_sam_ro;

grant select on samqa.ach_ee_terminated_v to sgali;

