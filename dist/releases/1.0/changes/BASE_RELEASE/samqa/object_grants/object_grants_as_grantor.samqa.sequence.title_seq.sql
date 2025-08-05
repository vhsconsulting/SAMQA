-- liquibase formatted sql
-- changeset SAMQA:1754373938293 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.title_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.title_seq.sql:null:99555f91adf9641f03fac7922c068fd8a176e7df:create

grant select on samqa.title_seq to rl_sam_rw;

