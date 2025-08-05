-- liquibase formatted sql
-- changeset SAMQA:1754373940641 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.gp_fee_error_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.gp_fee_error_external.sql:null:5d55f415a6e9c6fcfe06565c85291f03171df1ef:create

grant select on samqa.gp_fee_error_external to rl_sam1_ro;

grant select on samqa.gp_fee_error_external to rl_sam_ro;

