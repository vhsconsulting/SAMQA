-- liquibase formatted sql
-- changeset SAMQA:1754373944043 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_employees_queens_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_employees_queens_v.sql:null:0d6b4740c46454b55619c69b0cdef89fb7d278d3:create

grant select on samqa.fsa_hra_employees_queens_v to rl_sam1_ro;

grant select on samqa.fsa_hra_employees_queens_v to rl_sam_rw;

grant select on samqa.fsa_hra_employees_queens_v to rl_sam_ro;

