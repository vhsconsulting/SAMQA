-- liquibase formatted sql
-- changeset SAMQA:1754373942833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ach_transfer_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ach_transfer_v.sql:null:b32a799ca6e0621982dedcb2ae3abe07d9f56a1e:create

grant select on samqa.ach_transfer_v to rl_sam1_ro;

grant select on samqa.ach_transfer_v to rl_sam_rw;

grant select on samqa.ach_transfer_v to rl_sam_ro;

grant select on samqa.ach_transfer_v to sgali;

