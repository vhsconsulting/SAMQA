-- liquibase formatted sql
-- changeset SAMQA:1754373943715 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employer_hra_welcome_letter.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employer_hra_welcome_letter.sql:null:bf92e05f6b9f88b91f61f73979c1d02106daf7bc:create

grant select on samqa.employer_hra_welcome_letter to rl_sam1_ro;

grant select on samqa.employer_hra_welcome_letter to rl_sam_rw;

grant select on samqa.employer_hra_welcome_letter to rl_sam_ro;

grant select on samqa.employer_hra_welcome_letter to sgali;

