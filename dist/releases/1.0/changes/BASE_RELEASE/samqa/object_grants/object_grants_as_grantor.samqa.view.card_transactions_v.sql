-- liquibase formatted sql
-- changeset SAMQA:1754373943214 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.card_transactions_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.card_transactions_v.sql:null:57c6bcea18a4af024c48b73bf0d556529db11ebf:create

grant select on samqa.card_transactions_v to rl_sam1_ro;

grant select on samqa.card_transactions_v to rl_sam_rw;

grant select on samqa.card_transactions_v to rl_sam_ro;

grant select on samqa.card_transactions_v to sgali;

