-- liquibase formatted sql
-- changeset SAMQA:1754373943341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_status.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_status.sql:null:8719c7480bd3405f7aace3c3b4ea121d7d9b5347:create

grant select on samqa.claim_status to rl_sam1_ro;

grant select on samqa.claim_status to rl_sam_rw;

grant select on samqa.claim_status to rl_sam_ro;

grant select on samqa.claim_status to sgali;

