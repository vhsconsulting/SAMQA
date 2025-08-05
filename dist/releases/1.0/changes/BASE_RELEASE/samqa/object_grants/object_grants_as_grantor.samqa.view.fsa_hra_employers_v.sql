-- liquibase formatted sql
-- changeset SAMQA:1754373944058 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_employers_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_employers_v.sql:null:ca1e7c1e6142302cd9fec8668d7f3adfbbe1c3bd:create

grant select on samqa.fsa_hra_employers_v to rl_sam1_ro;

grant select on samqa.fsa_hra_employers_v to rl_sam_rw;

grant select on samqa.fsa_hra_employers_v to rl_sam_ro;

grant select on samqa.fsa_hra_employers_v to sgali;

