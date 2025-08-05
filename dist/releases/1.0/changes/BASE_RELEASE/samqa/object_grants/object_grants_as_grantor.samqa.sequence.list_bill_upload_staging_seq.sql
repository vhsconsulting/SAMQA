-- liquibase formatted sql
-- changeset SAMQA:1754373937923 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.list_bill_upload_staging_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.list_bill_upload_staging_seq.sql:null:19c042bbda4fc1e2117bcfed64ff1119026f4d75:create

grant select on samqa.list_bill_upload_staging_seq to rl_sam_rw;

