-- liquibase formatted sql
-- changeset SAMQA:1754373938198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.sales_comm_det_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.sales_comm_det_seq.sql:null:49d2c4bc6d2750a7e75aa713b504459700ae2319:create

grant select on samqa.sales_comm_det_seq to rl_sam_rw;

