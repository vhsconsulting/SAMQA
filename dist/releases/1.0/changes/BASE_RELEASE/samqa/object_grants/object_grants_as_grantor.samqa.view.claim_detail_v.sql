-- liquibase formatted sql
-- changeset SAMQA:1754373943278 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_detail_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_detail_v.sql:null:6f3fd6049d4ac118b6bd0ab4526561c6c4c93ea6:create

grant select on samqa.claim_detail_v to rl_sam1_ro;

grant select on samqa.claim_detail_v to rl_sam_rw;

grant select on samqa.claim_detail_v to rl_sam_ro;

grant select on samqa.claim_detail_v to sgali;

