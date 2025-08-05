-- liquibase formatted sql
-- changeset SAMQA:1754373938189 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.relative_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.relative_seq.sql:null:554aac2645381af44581b6567e4b4ded5aafd875:create

grant select on samqa.relative_seq to rl_sam_rw;

