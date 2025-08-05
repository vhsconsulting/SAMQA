-- liquibase formatted sql
-- changeset SAMQA:1754373937769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.expense_type_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.expense_type_seq.sql:null:95c2dff79eb0e19ebb2c45da761fd8b824854da2:create

grant select on samqa.expense_type_seq to rl_sam_rw;

