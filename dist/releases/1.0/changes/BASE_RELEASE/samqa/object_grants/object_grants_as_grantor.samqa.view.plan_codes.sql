-- liquibase formatted sql
-- changeset SAMQA:1754373944938 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.plan_codes.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.plan_codes.sql:null:439489a8ca536d4591027f68af52287653f7995e:create

grant select on samqa.plan_codes to rl_sam1_ro;

grant select on samqa.plan_codes to rl_sam_rw;

grant select on samqa.plan_codes to rl_sam_ro;

grant select on samqa.plan_codes to sgali;

