-- liquibase formatted sql
-- changeset SAMQA:1754373938309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.user_bank_acct_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.user_bank_acct_seq.sql:null:44d79579ffb2305db30fe68577be3587031ac2b3:create

grant select on samqa.user_bank_acct_seq to rl_sam_rw;

