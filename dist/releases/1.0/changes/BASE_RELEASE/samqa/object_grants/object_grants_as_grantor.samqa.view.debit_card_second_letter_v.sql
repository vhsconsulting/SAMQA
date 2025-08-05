-- liquibase formatted sql
-- changeset SAMQA:1754373943513 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.debit_card_second_letter_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.debit_card_second_letter_v.sql:null:f22b9a181dfdfc79e187e134cf47b6990fed03e8:create

grant select on samqa.debit_card_second_letter_v to rl_sam1_ro;

grant select on samqa.debit_card_second_letter_v to rl_sam_rw;

grant select on samqa.debit_card_second_letter_v to rl_sam_ro;

grant select on samqa.debit_card_second_letter_v to sgali;

