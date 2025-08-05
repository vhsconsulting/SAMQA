-- liquibase formatted sql
-- changeset SAMQA:1754373943552 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.ee_deposits_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.ee_deposits_v.sql:null:be428fdf600211522a2a285dfb0e914c8aa34ed4:create

grant select on samqa.ee_deposits_v to rl_sam1_ro;

grant select on samqa.ee_deposits_v to rl_sam_rw;

grant select on samqa.ee_deposits_v to rl_sam_ro;

grant select on samqa.ee_deposits_v to sgali;

