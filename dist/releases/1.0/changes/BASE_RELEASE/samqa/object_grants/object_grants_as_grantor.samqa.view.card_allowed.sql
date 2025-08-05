-- liquibase formatted sql
-- changeset SAMQA:1754373943198 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.card_allowed.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.card_allowed.sql:null:41f7bdeaa89ee8311d651e3187c500f374a89d5e:create

grant select on samqa.card_allowed to rl_sam1_ro;

grant select on samqa.card_allowed to rl_sam_rw;

grant select on samqa.card_allowed to rl_sam_ro;

grant select on samqa.card_allowed to sgali;

