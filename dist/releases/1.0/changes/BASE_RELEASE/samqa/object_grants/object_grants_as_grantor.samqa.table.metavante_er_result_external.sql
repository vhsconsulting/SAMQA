-- liquibase formatted sql
-- changeset SAMQA:1754373941166 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.metavante_er_result_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.metavante_er_result_external.sql:null:3d0da27245e7a29fe73d0fff4225c571def72da5:create

grant select on samqa.metavante_er_result_external to rl_sam1_ro;

grant select on samqa.metavante_er_result_external to rl_sam_ro;

