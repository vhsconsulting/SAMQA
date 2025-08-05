-- liquibase formatted sql
-- changeset SAMQA:1754373937391 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.benefit_codes_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.benefit_codes_seq.sql:null:ac245b5dcf1ea94d848c96e809b3f5e9b9f76d4f:create

grant select on samqa.benefit_codes_seq to rl_sam_rw;

