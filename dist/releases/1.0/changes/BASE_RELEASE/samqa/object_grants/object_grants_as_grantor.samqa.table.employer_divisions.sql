-- liquibase formatted sql
-- changeset SAMQA:1754373939952 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.employer_divisions.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.employer_divisions.sql:null:3b5fe3333a22163368b70c44d8ff9c247314b000:create

grant delete on samqa.employer_divisions to rl_sam_rw;

grant insert on samqa.employer_divisions to rl_sam_rw;

grant select on samqa.employer_divisions to rl_sam1_ro;

grant select on samqa.employer_divisions to rl_sam_rw;

grant select on samqa.employer_divisions to rl_sam_ro;

grant update on samqa.employer_divisions to rl_sam_rw;

