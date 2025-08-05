-- liquibase formatted sql
-- changeset SAMQA:1754373937582 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.ded_balance_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.ded_balance_seq.sql:null:51cc2efe344b742e571f0aad0c042a4e80debf06:create

grant select on samqa.ded_balance_seq to rl_sam_rw;

