-- liquibase formatted sql
-- changeset SAMQA:1754373935460 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.function.getage.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.function.getage.sql:null:0b309970b856d50633a27bb71d688980af1648a9:create

grant execute on samqa.getage to rl_sam_ro;

