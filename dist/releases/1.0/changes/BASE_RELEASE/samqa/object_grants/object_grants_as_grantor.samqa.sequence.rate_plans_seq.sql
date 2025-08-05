-- liquibase formatted sql
-- changeset SAMQA:1754373938166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.rate_plans_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.rate_plans_seq.sql:null:64fe7f566766210d9b46292a6458eaf3deac6a73:create

grant select on samqa.rate_plans_seq to rl_sam_rw;

