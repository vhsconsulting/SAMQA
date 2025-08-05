-- liquibase formatted sql
-- changeset SAMQA:1754373937527 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.compliance_quote_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.compliance_quote_seq.sql:null:9deda6ee07d6d000606231f7e1620664f38cbab7:create

grant select on samqa.compliance_quote_seq to rl_sam_rw;

