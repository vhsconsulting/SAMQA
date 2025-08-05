-- liquibase formatted sql
-- changeset SAMQA:1754373943230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.card_transfer_acc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.card_transfer_acc.sql:null:f02acb0996f84a9b903e372bbb64a776a53eb7be:create

grant select on samqa.card_transfer_acc to rl_sam1_ro;

grant select on samqa.card_transfer_acc to rl_sam_rw;

grant select on samqa.card_transfer_acc to rl_sam_ro;

grant select on samqa.card_transfer_acc to sgali;

