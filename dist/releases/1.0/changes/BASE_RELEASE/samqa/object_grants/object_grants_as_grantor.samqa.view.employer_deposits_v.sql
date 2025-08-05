-- liquibase formatted sql
-- changeset SAMQA:1754373943701 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.employer_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.employer_deposits_v.sql:null:8a3637f5b45ffaeb9f4a62d9d65268e3b229bd95:create

grant select on samqa.employer_deposits_v to rl_sam1_ro;

grant select on samqa.employer_deposits_v to rl_sam_rw;

grant select on samqa.employer_deposits_v to rl_sam_ro;

grant select on samqa.employer_deposits_v to sgali;

