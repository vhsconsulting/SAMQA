-- liquibase formatted sql
-- changeset SAMQA:1754373938166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.receipt_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.receipt_id_seq.sql:null:e9b01eaa0948226639c6617dfee70d1b1e3d78d4:create

grant select on samqa.receipt_id_seq to rl_sam_rw;

