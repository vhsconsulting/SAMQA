-- liquibase formatted sql
-- changeset SAMQA:1754373944554 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.metavante_dep_cards_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.metavante_dep_cards_v.sql:null:0c048fb7f4e53b7065ee354db3c08ed82e43e8a4:create

grant select on samqa.metavante_dep_cards_v to rl_sam1_ro;

grant select on samqa.metavante_dep_cards_v to rl_sam_rw;

grant select on samqa.metavante_dep_cards_v to rl_sam_ro;

grant select on samqa.metavante_dep_cards_v to sgali;

