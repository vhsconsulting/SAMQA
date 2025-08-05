-- liquibase formatted sql
-- changeset SAMQA:1754373938849 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bankserv_pins.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bankserv_pins.sql:null:15788a63cdece7d9bfbb47ddc5928d85e0f5ba40:create

grant delete on samqa.bankserv_pins to rl_sam_rw;

grant insert on samqa.bankserv_pins to rl_sam_rw;

grant select on samqa.bankserv_pins to rl_sam1_ro;

grant select on samqa.bankserv_pins to rl_sam_rw;

grant select on samqa.bankserv_pins to rl_sam_ro;

grant update on samqa.bankserv_pins to rl_sam_rw;

