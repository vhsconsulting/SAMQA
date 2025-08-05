-- liquibase formatted sql
-- changeset SAMQA:1754373941568 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.pay_details.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.pay_details.sql:null:bc7ce0729db7a943c66159ed67439b9b808ca82a:create

grant delete on samqa.pay_details to rl_sam_rw;

grant insert on samqa.pay_details to rl_sam_rw;

grant select on samqa.pay_details to rl_sam1_ro;

grant select on samqa.pay_details to rl_sam_rw;

grant select on samqa.pay_details to rl_sam_ro;

grant update on samqa.pay_details to rl_sam_rw;

