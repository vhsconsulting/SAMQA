-- liquibase formatted sql
-- changeset SAMQA:1754373939478 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.cobra_er_terminated_accounts.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.cobra_er_terminated_accounts.sql:null:d7f57281dbdfb2953665e5dda8e735a97d5736cc:create

grant delete on samqa.cobra_er_terminated_accounts to rl_sam_rw;

grant insert on samqa.cobra_er_terminated_accounts to rl_sam_rw;

grant select on samqa.cobra_er_terminated_accounts to rl_sam1_ro;

grant select on samqa.cobra_er_terminated_accounts to rl_sam_ro;

grant select on samqa.cobra_er_terminated_accounts to rl_sam_rw;

grant update on samqa.cobra_er_terminated_accounts to rl_sam_rw;

