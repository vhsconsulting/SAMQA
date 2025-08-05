-- liquibase formatted sql
-- changeset SAMQA:1754373939002 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bill_format_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bill_format_staging.sql:null:2846541e4fff24c326f8856ebc13d03abbaed470:create

grant delete on samqa.bill_format_staging to rl_sam_rw;

grant insert on samqa.bill_format_staging to rl_sam_rw;

grant select on samqa.bill_format_staging to rl_sam1_ro;

grant select on samqa.bill_format_staging to rl_sam_rw;

grant select on samqa.bill_format_staging to rl_sam_ro;

grant update on samqa.bill_format_staging to rl_sam_rw;

