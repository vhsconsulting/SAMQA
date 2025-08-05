-- liquibase formatted sql
-- changeset SAMQA:1754373940683 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_receipt_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_receipt_result_external.sql:null:57aa39f8a9bebf6414ff5c1d856a0b044fed31a9:create

grant select on samqa.gp_receipt_result_external to rl_sam1_ro;

grant select on samqa.gp_receipt_result_external to rl_sam_ro;

