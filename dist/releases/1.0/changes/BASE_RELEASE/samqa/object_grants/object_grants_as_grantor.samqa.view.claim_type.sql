-- liquibase formatted sql
-- changeset SAMQA:1754373943341 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.claim_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.claim_type.sql:null:a730e883dbdbbb73c139c0ec49f605fcb8c935ee:create

grant select on samqa.claim_type to rl_sam1_ro;

grant select on samqa.claim_type to rl_sam_rw;

grant select on samqa.claim_type to rl_sam_ro;

grant select on samqa.claim_type to sgali;

