-- liquibase formatted sql
-- changeset SAMQA:1754373938189 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.receivable_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.receivable_seq.sql:null:cf733b30f15d0bceacaf6530e3a3bf5d37df2a7c:create

grant select on samqa.receivable_seq to rl_sam_rw;

