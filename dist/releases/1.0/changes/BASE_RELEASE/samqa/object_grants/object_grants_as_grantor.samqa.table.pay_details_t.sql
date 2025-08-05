-- liquibase formatted sql
-- changeset SAMQA:1754373941576 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.pay_details_t.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.pay_details_t.sql:null:22a74fbbadaecd0c2275c7e670df9ba5c9e1fe51:create

grant delete on samqa.pay_details_t to rl_sam_rw;

grant insert on samqa.pay_details_t to rl_sam_rw;

grant select on samqa.pay_details_t to rl_sam1_ro;

grant select on samqa.pay_details_t to rl_sam_rw;

grant select on samqa.pay_details_t to rl_sam_ro;

grant update on samqa.pay_details_t to rl_sam_rw;

