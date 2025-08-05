-- liquibase formatted sql
-- changeset SAMQA:1754373937357 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.bank_rate_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.bank_rate_seq.sql:null:e9b3ed78dfe3ac64623a7ffe6276e6fc378b16c4:create

grant select on samqa.bank_rate_seq to rl_sam_rw;

