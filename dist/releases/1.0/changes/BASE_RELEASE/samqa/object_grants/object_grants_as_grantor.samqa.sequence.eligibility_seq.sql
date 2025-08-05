-- liquibase formatted sql
-- changeset SAMQA:1754373937661 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.eligibility_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.eligibility_seq.sql:null:f142256503672dbb98c1a9c32b81141ae9e97f46:create

grant select on samqa.eligibility_seq to rl_sam_rw;

