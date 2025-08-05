-- liquibase formatted sql
-- changeset SAMQA:1754373944544 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.metavante_cards_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.metavante_cards_v.sql:null:197a832442dd575b209cdd7dc09c0f69fd73f6cb:create

grant select on samqa.metavante_cards_v to rl_sam1_ro;

grant select on samqa.metavante_cards_v to rl_sam_rw;

grant select on samqa.metavante_cards_v to rl_sam_ro;

grant select on samqa.metavante_cards_v to sgali;

