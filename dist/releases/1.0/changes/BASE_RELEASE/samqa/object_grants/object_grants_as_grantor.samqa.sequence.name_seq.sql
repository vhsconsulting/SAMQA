-- liquibase formatted sql
-- changeset SAMQA:1754373938029 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.name_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.name_seq.sql:null:2fe6ff47d20fe6a5176d1f65531d7e532d52392c:create

grant select on samqa.name_seq to rl_sam_rw;

