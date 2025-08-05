-- liquibase formatted sql
-- changeset SAMQA:1754373943989 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_employees_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_employees_v.sql:null:7e59892f70d5f839c5395741189820bf927d6ebc:create

grant select on samqa.fsa_employees_v to rl_sam1_ro;

grant select on samqa.fsa_employees_v to rl_sam_rw;

grant select on samqa.fsa_employees_v to rl_sam_ro;

grant select on samqa.fsa_employees_v to sgali;

