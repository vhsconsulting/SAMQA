-- liquibase formatted sql
-- changeset SAMQA:1754373937657 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.eligibility_expense_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.eligibility_expense_seq.sql:null:917d2a319a4175c8aae5994b0b780adc0e2e228c:create

grant select on samqa.eligibility_expense_seq to rl_sam_rw;

