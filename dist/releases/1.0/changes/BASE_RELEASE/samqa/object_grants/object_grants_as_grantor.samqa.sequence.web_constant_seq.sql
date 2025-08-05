-- liquibase formatted sql
-- changeset SAMQA:1754373938343 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.web_constant_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.web_constant_seq.sql:null:50911522984c8ec584ea77740488ce0521be9687:create

grant select on samqa.web_constant_seq to rl_sam_rw;

