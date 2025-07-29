-- liquibase formatted sql
-- changeset SAMQA:1753779564372 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.opportunity_notifications.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.opportunity_notifications.sql:null:5ca7d3cbf842eb0300cbd48ecda138a83aa3571b:create

grant select on samqa.opportunity_notifications to rl_sam_ro;

