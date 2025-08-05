-- liquibase formatted sql
-- changeset SAMQA:1754373938325 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.user_bank_acct_stg_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.user_bank_acct_stg_seq.sql:null:4d7737aeb3875465b9b69cbeb62616882625f248:create

grant select on samqa.user_bank_acct_stg_seq to rl_sam_rw;

