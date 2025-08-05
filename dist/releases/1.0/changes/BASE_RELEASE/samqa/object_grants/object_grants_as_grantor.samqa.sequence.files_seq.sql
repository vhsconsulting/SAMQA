-- liquibase formatted sql
-- changeset SAMQA:1754373937801 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.files_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.files_seq.sql:null:90ae3b62f2a00c480c072b454a41d591789d6b1c:create

grant select on samqa.files_seq to rl_sam_rw;

