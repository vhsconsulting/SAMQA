-- liquibase formatted sql
-- changeset SAMQA:1754373943297 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_documents_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_documents_v.sql:null:e4978f3d9d0a4425605e0565d85e71c41515c236:create

grant select on samqa.claim_documents_v to rl_sam1_ro;

grant select on samqa.claim_documents_v to rl_sam_rw;

grant select on samqa.claim_documents_v to rl_sam_ro;

grant select on samqa.claim_documents_v to sgali;

