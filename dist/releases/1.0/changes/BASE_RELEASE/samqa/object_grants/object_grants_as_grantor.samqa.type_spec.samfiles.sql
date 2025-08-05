-- liquibase formatted sql
-- changeset SAMQA:1754373942629 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.samfiles.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.samfiles.sql:null:fbc9f0555131180b92ec9ba912341eed6d1f94ee:create

grant execute on samqa.samfiles to rl_sam1_ro;

grant execute on samqa.samfiles to rl_sam_ro;

grant execute on samqa.samfiles to rl_sam_rw;

