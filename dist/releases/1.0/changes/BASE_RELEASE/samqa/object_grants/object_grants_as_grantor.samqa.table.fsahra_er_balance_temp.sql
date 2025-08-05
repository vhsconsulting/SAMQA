-- liquibase formatted sql
-- changeset SAMQA:1754373940561 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.fsahra_er_balance_temp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.fsahra_er_balance_temp.sql:null:570a05d870a6dbead87b6d60ca91b492d4cd4006:create

grant delete on samqa.fsahra_er_balance_temp to rl_sam_rw;

grant insert on samqa.fsahra_er_balance_temp to rl_sam_rw;

grant select on samqa.fsahra_er_balance_temp to rl_sam1_ro;

grant select on samqa.fsahra_er_balance_temp to rl_sam_ro;

grant select on samqa.fsahra_er_balance_temp to rl_sam_rw;

grant update on samqa.fsahra_er_balance_temp to rl_sam_rw;

