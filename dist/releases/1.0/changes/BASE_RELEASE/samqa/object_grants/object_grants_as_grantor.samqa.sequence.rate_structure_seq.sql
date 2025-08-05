-- liquibase formatted sql
-- changeset SAMQA:1754373938166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.rate_structure_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.rate_structure_seq.sql:null:74dba6b034e22fe52de373376571ba4247f86d48:create

grant select on samqa.rate_structure_seq to rl_sam_rw;

