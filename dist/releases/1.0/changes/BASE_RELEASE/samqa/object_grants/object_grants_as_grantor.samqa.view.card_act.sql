-- liquibase formatted sql
-- changeset SAMQA:1754373943182 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.card_act.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.card_act.sql:null:a5b9befaa1e27730b1d801217a2598b8bd8bf5c9:create

grant select on samqa.card_act to rl_sam1_ro;

grant select on samqa.card_act to rl_sam_rw;

grant select on samqa.card_act to rl_sam_ro;

grant select on samqa.card_act to sgali;

