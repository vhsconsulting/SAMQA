-- liquibase formatted sql
-- changeset SAMQA:1754373941104 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.mcc_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.mcc_codes.sql:null:0cc4baa17facfb7fadf013c4ad6301c5e95571aa:create

grant delete on samqa.mcc_codes to rl_sam_rw;

grant insert on samqa.mcc_codes to rl_sam_rw;

grant select on samqa.mcc_codes to rl_sam_ro;

grant select on samqa.mcc_codes to rl_sam1_ro;

grant select on samqa.mcc_codes to rl_sam_rw;

grant update on samqa.mcc_codes to rl_sam_rw;

