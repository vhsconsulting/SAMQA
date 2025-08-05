-- liquibase formatted sql
-- changeset SAMQA:1754373939737 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.del_income_cobra.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.del_income_cobra.sql:null:ce379b1dca167d9da40e1484c0288d33c3696aef:create

grant delete on samqa.del_income_cobra to rl_sam_rw;

grant insert on samqa.del_income_cobra to rl_sam_rw;

grant select on samqa.del_income_cobra to rl_sam1_ro;

grant select on samqa.del_income_cobra to rl_sam_ro;

grant select on samqa.del_income_cobra to rl_sam_rw;

grant update on samqa.del_income_cobra to rl_sam_rw;

