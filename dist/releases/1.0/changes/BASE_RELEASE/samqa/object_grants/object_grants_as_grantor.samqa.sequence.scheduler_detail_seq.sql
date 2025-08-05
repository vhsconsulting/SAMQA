-- liquibase formatted sql
-- changeset SAMQA:1754373938246 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.scheduler_detail_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.scheduler_detail_seq.sql:null:26596d4ea6c37f1e4e7d70d6502bffca683f16ec:create

grant select on samqa.scheduler_detail_seq to rl_sam_rw;

