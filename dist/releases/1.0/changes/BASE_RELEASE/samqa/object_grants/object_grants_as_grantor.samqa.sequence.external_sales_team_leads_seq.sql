-- liquibase formatted sql
-- changeset SAMQA:1754373937769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.external_sales_team_leads_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.external_sales_team_leads_seq.sql:null:9f33b683faec696df8843c453fd5ded51742222f:create

grant select on samqa.external_sales_team_leads_seq to rl_sam_rw;

