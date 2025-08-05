-- liquibase formatted sql
-- changeset SAMQA:1754373945283 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.temp_metavante_cards_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.temp_metavante_cards_v.sql:null:a4fa13388757fb3df071176802c33921becbcf3f:create

grant select on samqa.temp_metavante_cards_v to rl_sam_rw;

grant select on samqa.temp_metavante_cards_v to rl_sam_ro;

grant select on samqa.temp_metavante_cards_v to sgali;

grant select on samqa.temp_metavante_cards_v to rl_sam1_ro;

