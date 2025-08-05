-- liquibase formatted sql
-- changeset SAMQA:1754373943230 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.cards_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.cards_v.sql:null:def14cbfd47ea7382da37ce6fd8a2906f8ea2d36:create

grant select on samqa.cards_v to rl_sam1_ro;

grant select on samqa.cards_v to rl_sam_rw;

grant select on samqa.cards_v to rl_sam_ro;

grant select on samqa.cards_v to sgali;

