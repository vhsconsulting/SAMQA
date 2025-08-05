-- liquibase formatted sql
-- changeset SAMQA:1754373937865 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.invoice_parameters_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.invoice_parameters_seq.sql:null:d6df29cb12651aad31f6a0355febac8b946fe9dd:create

grant select on samqa.invoice_parameters_seq to rl_sam_rw;

