-- liquibase formatted sql
-- changeset SAMQA:1754373942611 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.type_spec.samblobs.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.type_spec.samblobs.sql:null:ed73b50b57aa97f7af7cfc61c80f68ede11bbd39:create

grant execute on samqa.samblobs to rl_sam1_ro;

grant execute on samqa.samblobs to rl_sam_ro;

grant execute on samqa.samblobs to rl_sam_rw;

