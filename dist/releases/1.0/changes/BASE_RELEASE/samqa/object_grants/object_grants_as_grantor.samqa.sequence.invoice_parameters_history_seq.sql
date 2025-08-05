-- liquibase formatted sql
-- changeset SAMQA:1754373937865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.invoice_parameters_history_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.invoice_parameters_history_seq.sql:null:1b8726f1869020f15f004c2b323d013ff8ae276b:create

grant select on samqa.invoice_parameters_history_seq to rl_sam_rw;

