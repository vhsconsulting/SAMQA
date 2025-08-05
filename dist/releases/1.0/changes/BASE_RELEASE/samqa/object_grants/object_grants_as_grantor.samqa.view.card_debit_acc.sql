-- liquibase formatted sql
-- changeset SAMQA:1754373943198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.card_debit_acc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.card_debit_acc.sql:null:a8f4cd533a527fd348cad67d0f87cd0c3f5f6bac:create

grant select on samqa.card_debit_acc to rl_sam1_ro;

grant select on samqa.card_debit_acc to rl_sam_rw;

grant select on samqa.card_debit_acc to rl_sam_ro;

grant select on samqa.card_debit_acc to sgali;

