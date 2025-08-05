-- liquibase formatted sql
-- changeset SAMQA:1754373938107 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.pay_reason_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.pay_reason_seq.sql:null:4066974eb8eea5b3dc6d6f214f3a25b6180e2125:create

grant select on samqa.pay_reason_seq to rl_sam_rw;

