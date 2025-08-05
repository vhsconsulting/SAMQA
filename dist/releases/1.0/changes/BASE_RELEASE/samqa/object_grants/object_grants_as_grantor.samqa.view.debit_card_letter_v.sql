-- liquibase formatted sql
-- changeset SAMQA:1754373943506 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.debit_card_letter_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.debit_card_letter_v.sql:null:1d2ded3e7f34ea5089becca271559853cd07743d:create

grant select on samqa.debit_card_letter_v to rl_sam1_ro;

grant select on samqa.debit_card_letter_v to rl_sam_rw;

grant select on samqa.debit_card_letter_v to rl_sam_ro;

grant select on samqa.debit_card_letter_v to sgali;

