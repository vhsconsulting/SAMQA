-- liquibase formatted sql
-- changeset SAMQA:1754373943443 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.crm_broker_import_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.crm_broker_import_v.sql:null:b9dfc320c6626080d3e74ab35753aafd9175063c:create

grant select on samqa.crm_broker_import_v to rl_sam1_ro;

grant select on samqa.crm_broker_import_v to rl_sam_ro;

grant select on samqa.crm_broker_import_v to rl_sam_rw;

