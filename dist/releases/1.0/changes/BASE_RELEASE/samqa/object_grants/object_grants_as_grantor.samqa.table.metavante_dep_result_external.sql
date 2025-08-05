-- liquibase formatted sql
-- changeset SAMQA:1754373941150 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_dep_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_dep_result_external.sql:null:19dfa2dad6cebe06d5cb695ff822c0a9df60496f:create

grant select on samqa.metavante_dep_result_external to rl_sam1_ro;

grant select on samqa.metavante_dep_result_external to rl_sam_ro;

