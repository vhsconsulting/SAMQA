-- liquibase formatted sql
-- changeset SAMQA:1754373937679 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.employer_payments_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.employer_payments_seq.sql:null:b5ae126e3cf0f28f407ae239e908b1d2efa1066f:create

grant select on samqa.employer_payments_seq to rl_sam_rw;

