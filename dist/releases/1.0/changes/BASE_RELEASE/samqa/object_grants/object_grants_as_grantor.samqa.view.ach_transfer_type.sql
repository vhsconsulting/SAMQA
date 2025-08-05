-- liquibase formatted sql
-- changeset SAMQA:1754373942833 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ach_transfer_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ach_transfer_type.sql:null:d85fde3ea5459061dcb6d5d497201e63ee25d983:create

grant select on samqa.ach_transfer_type to rl_sam1_ro;

grant select on samqa.ach_transfer_type to rl_sam_rw;

grant select on samqa.ach_transfer_type to rl_sam_ro;

grant select on samqa.ach_transfer_type to sgali;

