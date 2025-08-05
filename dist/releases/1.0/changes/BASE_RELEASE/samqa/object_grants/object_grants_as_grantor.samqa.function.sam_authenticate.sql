-- liquibase formatted sql
-- changeset SAMQA:1754373935557 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.sam_authenticate.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.sam_authenticate.sql:null:992d0adccdbdecaa0e32b8dd9bed9f753f1b7e89:create

grant execute on samqa.sam_authenticate to rl_sam_ro;

