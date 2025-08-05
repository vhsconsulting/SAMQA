-- liquibase formatted sql
-- changeset SAMQA:1754373944112 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.fsa_hra_sugar_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.fsa_hra_sugar_v.sql:null:93ad0299f2742eea9c983a73280b8550565262c3:create

grant select on samqa.fsa_hra_sugar_v to rl_sam1_ro;

grant select on samqa.fsa_hra_sugar_v to rl_sam_ro;

grant select on samqa.fsa_hra_sugar_v to rl_sam_rw;

