-- liquibase formatted sql
-- changeset SAMQA:1754373940577 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.general_agent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.general_agent.sql:null:5cb4d0a3494aee8e483630ace8ce6bee57c51014:create

grant delete on samqa.general_agent to rl_sam_rw;

grant insert on samqa.general_agent to rl_sam_rw;

grant select on samqa.general_agent to rl_sam_ro;

grant select on samqa.general_agent to rl_sam1_ro;

grant select on samqa.general_agent to rl_sam_rw;

grant update on samqa.general_agent to rl_sam_rw;

