-- liquibase formatted sql
-- changeset SAMQA:1754373944260 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.hra_er_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.hra_er_deposits_v.sql:null:b8f1ae3121bc560a5c4e5b25cd239355b22afbde:create

grant select on samqa.hra_er_deposits_v to rl_sam1_ro;

grant select on samqa.hra_er_deposits_v to rl_sam_ro;

grant select on samqa.hra_er_deposits_v to rl_sam_rw;

