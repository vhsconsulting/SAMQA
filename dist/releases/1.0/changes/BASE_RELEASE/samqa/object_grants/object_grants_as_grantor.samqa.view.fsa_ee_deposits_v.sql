-- liquibase formatted sql
-- changeset SAMQA:1754373943979 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_ee_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_ee_deposits_v.sql:null:72fcc4c9fb67e1eaf70afd85cb134179fe4c7739:create

grant select on samqa.fsa_ee_deposits_v to rl_sam1_ro;

grant select on samqa.fsa_ee_deposits_v to rl_sam_rw;

grant select on samqa.fsa_ee_deposits_v to rl_sam_ro;

grant select on samqa.fsa_ee_deposits_v to sgali;

