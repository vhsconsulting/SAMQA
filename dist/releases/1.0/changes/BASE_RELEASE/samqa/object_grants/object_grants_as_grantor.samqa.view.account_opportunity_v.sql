-- liquibase formatted sql
-- changeset SAMQA:1754373942751 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.view.account_opportunity_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.view.account_opportunity_v.sql:null:7d49d40e98f77c7aa7633c4ac851cf85286ef548:create

grant select on samqa.account_opportunity_v to rl_sam_ro;

