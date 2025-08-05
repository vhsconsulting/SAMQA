-- liquibase formatted sql
-- changeset SAMQA:1754373937522 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.compliance_quote_lines_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.compliance_quote_lines_seq.sql:null:caad433b7cac31256a252a85e4856dbd9d959f5a:create

grant select on samqa.compliance_quote_lines_seq to rl_sam_rw;

