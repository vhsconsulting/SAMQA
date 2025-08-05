-- liquibase formatted sql
-- changeset SAMQA:1754373942604 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.samblob.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.samblob.sql:null:ec6ddcf38a245c190da163730bbee2d57e993e5d:create

grant execute on samqa.samblob to rl_sam1_ro;

grant execute on samqa.samblob to rl_sam_ro;

grant execute on samqa.samblob to rl_sam_rw;

