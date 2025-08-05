-- liquibase formatted sql
-- changeset SAMQA:1754373944738 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.new_hire_contrib.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.new_hire_contrib.sql:null:c9b287082b93a3a2ae0ba49c73ea68dfcebbcf7e:create

grant select on samqa.new_hire_contrib to rl_sam1_ro;

grant select on samqa.new_hire_contrib to rl_sam_rw;

grant select on samqa.new_hire_contrib to rl_sam_ro;

grant select on samqa.new_hire_contrib to sgali;

