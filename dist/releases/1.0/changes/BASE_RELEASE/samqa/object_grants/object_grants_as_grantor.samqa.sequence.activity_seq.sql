-- liquibase formatted sql
-- changeset SAMQA:1754373937306 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.activity_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.activity_seq.sql:null:57bc9a89263abcff1bd85cbd1092ce22bcf842d4:create

grant select on samqa.activity_seq to rl_sam_rw;

