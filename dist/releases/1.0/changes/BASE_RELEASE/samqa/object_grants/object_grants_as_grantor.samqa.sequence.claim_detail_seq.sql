-- liquibase formatted sql
-- changeset SAMQA:1754373937464 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.claim_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.claim_detail_seq.sql:null:e859f33f6f86b8165efd63ad2b5b37775aaa798c:create

grant select on samqa.claim_detail_seq to rl_sam_rw;

