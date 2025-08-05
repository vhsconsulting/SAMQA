-- liquibase formatted sql
-- changeset SAMQA:1754373938343 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.website_forms_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.website_forms_seq.sql:null:957a392117b4b5bd899b55ddbb3de090a2895028:create

grant select on samqa.website_forms_seq to rl_sam_rw;

