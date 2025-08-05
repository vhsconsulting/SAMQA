-- liquibase formatted sql
-- changeset SAMQA:1754373940912 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.irs_acc_amendments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.irs_acc_amendments.sql:null:a94dbeb7ef936aa46463359cf362fc27798a4e68:create

grant delete on samqa.irs_acc_amendments to rl_sam_rw;

grant insert on samqa.irs_acc_amendments to rl_sam_rw;

grant select on samqa.irs_acc_amendments to rl_sam1_ro;

grant select on samqa.irs_acc_amendments to rl_sam_rw;

grant select on samqa.irs_acc_amendments to rl_sam_ro;

grant update on samqa.irs_acc_amendments to rl_sam_rw;

