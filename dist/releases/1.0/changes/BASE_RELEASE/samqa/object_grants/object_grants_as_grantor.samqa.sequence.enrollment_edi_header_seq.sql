-- liquibase formatted sql
-- changeset SAMQA:1754373937694 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.enrollment_edi_header_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.enrollment_edi_header_seq.sql:null:2c3c272ef537fbdbfba2c493edd29247d8f1abf1:create

grant select on samqa.enrollment_edi_header_seq to rl_sam_rw;

