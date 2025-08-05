-- liquibase formatted sql
-- changeset SAMQA:1754373944006 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_er_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_er_deposits_v.sql:null:06a3fb52604c08713070da307a2cfb4e5d5180a3:create

grant select on samqa.fsa_er_deposits_v to rl_sam1_ro;

grant select on samqa.fsa_er_deposits_v to rl_sam_rw;

grant select on samqa.fsa_er_deposits_v to rl_sam_ro;

grant select on samqa.fsa_er_deposits_v to sgali;

