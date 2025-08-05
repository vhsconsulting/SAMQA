-- liquibase formatted sql
-- changeset SAMQA:1754373938309 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.trc_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.trc_seq.sql:null:3649fbcf0705aa2137d4499c534d6ab8315b0e5b:create

grant select on samqa.trc_seq to rl_sam_rw;

