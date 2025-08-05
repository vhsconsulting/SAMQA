-- liquibase formatted sql
-- changeset SAMQA:1754373938479 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.ach_transfer_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.ach_transfer_external.sql:null:8fc9557b44c776f046156a76c353e1a577a08973:create

grant select on samqa.ach_transfer_external to rl_sam1_ro;

grant select on samqa.ach_transfer_external to rl_sam_ro;

