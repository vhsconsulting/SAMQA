-- liquibase formatted sql
-- changeset SAMQA:1754373935540 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.return_link_fn.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.return_link_fn.sql:null:c407f0c1a497f5dc381572f1ac9c0d2b098d777c:create

grant execute on samqa.return_link_fn to rl_sam_ro;

