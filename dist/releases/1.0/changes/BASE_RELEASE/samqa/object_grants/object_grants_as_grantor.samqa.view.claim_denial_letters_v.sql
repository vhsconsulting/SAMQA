-- liquibase formatted sql
-- changeset SAMQA:1754373943278 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_denial_letters_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_denial_letters_v.sql:null:8f06b9dbaac065524b31c4bae548ce2224fd2b12:create

grant select on samqa.claim_denial_letters_v to rl_sam1_ro;

grant select on samqa.claim_denial_letters_v to rl_sam_rw;

grant select on samqa.claim_denial_letters_v to rl_sam_ro;

grant select on samqa.claim_denial_letters_v to sgali;

