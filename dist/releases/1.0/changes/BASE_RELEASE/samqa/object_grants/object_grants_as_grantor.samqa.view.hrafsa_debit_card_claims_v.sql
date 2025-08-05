-- liquibase formatted sql
-- changeset SAMQA:1754373944324 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hrafsa_debit_card_claims_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hrafsa_debit_card_claims_v.sql:null:43df87a57b3c63cf96832fa3368e18c6aeabae9a:create

grant select on samqa.hrafsa_debit_card_claims_v to rl_sam1_ro;

grant select on samqa.hrafsa_debit_card_claims_v to rl_sam_rw;

grant select on samqa.hrafsa_debit_card_claims_v to rl_sam_ro;

grant select on samqa.hrafsa_debit_card_claims_v to sgali;

