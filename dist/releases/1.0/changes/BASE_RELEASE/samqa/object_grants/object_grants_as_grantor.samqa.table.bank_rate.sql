-- liquibase formatted sql
-- changeset SAMQA:1754373938836 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.bank_rate.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.bank_rate.sql:null:d9e249acc0b39407053c155f7a3973e90fdd9cd8:create

grant delete on samqa.bank_rate to rl_sam_rw;

grant insert on samqa.bank_rate to rl_sam_rw;

grant select on samqa.bank_rate to rl_sam_ro;

grant select on samqa.bank_rate to rl_sam1_ro;

grant select on samqa.bank_rate to rl_sam_rw;

grant update on samqa.bank_rate to rl_sam_rw;

