-- liquibase formatted sql
-- changeset SAMQA:1754373938230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.salesrep_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.salesrep_seq.sql:null:6b215ac41627bdb07ce7e6eb71fd16fe46d8fbe8:create

grant select on samqa.salesrep_seq to rl_sam_rw;

