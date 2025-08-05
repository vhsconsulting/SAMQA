-- liquibase formatted sql
-- changeset SAMQA:1754373943278 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_deny_code.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_deny_code.sql:null:ce5fcaddd04ce84bf503f713816ce3c7b2942c4b:create

grant select on samqa.claim_deny_code to rl_sam1_ro;

grant select on samqa.claim_deny_code to rl_sam_rw;

grant select on samqa.claim_deny_code to rl_sam_ro;

grant select on samqa.claim_deny_code to sgali;

