-- liquibase formatted sql
-- changeset SAMQA:1754373942218 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.subscriber_lead_external.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.subscriber_lead_external.sql:null:389b70c5856b96746ad18a5d30498771dfb85223:create

grant select on samqa.subscriber_lead_external to rl_sam1_ro;

grant select on samqa.subscriber_lead_external to rl_sam_ro;

