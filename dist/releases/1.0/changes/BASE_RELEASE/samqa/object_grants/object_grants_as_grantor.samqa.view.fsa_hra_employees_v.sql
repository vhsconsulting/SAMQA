-- liquibase formatted sql
-- changeset SAMQA:1754373944052 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_employees_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_employees_v.sql:null:19383f21968deaecce05f91c2133f158cd1521a7:create

grant select on samqa.fsa_hra_employees_v to rl_sam1_ro;

grant select on samqa.fsa_hra_employees_v to rl_sam_rw;

grant select on samqa.fsa_hra_employees_v to rl_sam_ro;

grant select on samqa.fsa_hra_employees_v to sgali;

