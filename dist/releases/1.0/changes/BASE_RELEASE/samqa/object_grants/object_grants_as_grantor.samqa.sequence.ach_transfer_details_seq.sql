-- liquibase formatted sql
-- changeset SAMQA:1754373937294 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ach_transfer_details_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ach_transfer_details_seq.sql:null:3ccbdfb6e8c3cf794f03044f99f73db2e92dc32f:create

grant select on samqa.ach_transfer_details_seq to rl_sam_rw;

