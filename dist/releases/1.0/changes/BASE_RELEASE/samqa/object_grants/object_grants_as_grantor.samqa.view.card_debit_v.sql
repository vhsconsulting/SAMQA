-- liquibase formatted sql
-- changeset SAMQA:1754373943198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.card_debit_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.card_debit_v.sql:null:d3ca007f4ef31a206928ef489279118431cd0376:create

grant select on samqa.card_debit_v to rl_sam1_ro;

grant select on samqa.card_debit_v to rl_sam_rw;

grant select on samqa.card_debit_v to rl_sam_ro;

grant select on samqa.card_debit_v to sgali;

