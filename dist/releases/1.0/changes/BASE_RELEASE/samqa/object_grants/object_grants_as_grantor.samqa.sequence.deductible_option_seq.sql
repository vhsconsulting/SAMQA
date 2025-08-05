-- liquibase formatted sql
-- changeset SAMQA:1754373937598 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.deductible_option_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.deductible_option_seq.sql:null:569ecd5f8452961adb41df9d42bc3cf24a1221bd:create

grant select on samqa.deductible_option_seq to rl_sam_rw;

