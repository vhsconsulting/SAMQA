-- liquibase formatted sql
-- changeset SAMQA:1754373938277 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.settlement_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.settlement_seq.sql:null:0d9395773c94d81ea32478bfd5b04b5cdcfe0232:create

grant select on samqa.settlement_seq to rl_sam_rw;

