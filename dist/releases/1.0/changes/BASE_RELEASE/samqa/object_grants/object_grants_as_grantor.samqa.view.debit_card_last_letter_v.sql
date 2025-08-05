-- liquibase formatted sql
-- changeset SAMQA:1754373943500 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.debit_card_last_letter_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.debit_card_last_letter_v.sql:null:cdfaf8694b70a51e8ccbefd4455f0e0ca77cf90b:create

grant select on samqa.debit_card_last_letter_v to rl_sam1_ro;

grant select on samqa.debit_card_last_letter_v to rl_sam_rw;

grant select on samqa.debit_card_last_letter_v to rl_sam_ro;

grant select on samqa.debit_card_last_letter_v to sgali;

