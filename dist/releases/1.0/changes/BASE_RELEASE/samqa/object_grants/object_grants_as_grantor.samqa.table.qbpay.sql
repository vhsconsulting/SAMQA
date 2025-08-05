-- liquibase formatted sql
-- changeset SAMQA:1754373941759 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.qbpay.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.qbpay.sql:null:ba4febc5ca2b5e220f55b2ec03538b8b770b0a34:create

grant delete on samqa.qbpay to rl_sam_rw;

grant insert on samqa.qbpay to rl_sam_rw;

grant select on samqa.qbpay to rl_sam1_ro;

grant select on samqa.qbpay to rl_sam_ro;

grant select on samqa.qbpay to rl_sam_rw;

grant update on samqa.qbpay to rl_sam_rw;

