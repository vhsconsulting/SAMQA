-- liquibase formatted sql
-- changeset SAMQA:1754373940839 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.invest_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.invest_transfer.sql:null:426ad240c20d96d507c416986950b4f6dac6c8a6:create

grant delete on samqa.invest_transfer to rl_sam_rw;

grant insert on samqa.invest_transfer to rl_sam_rw;

grant select on samqa.invest_transfer to rl_sam1_ro;

grant select on samqa.invest_transfer to rl_sam_rw;

grant select on samqa.invest_transfer to rl_sam_ro;

grant update on samqa.invest_transfer to rl_sam_rw;

