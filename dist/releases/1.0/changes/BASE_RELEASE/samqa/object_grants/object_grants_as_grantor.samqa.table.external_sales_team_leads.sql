-- liquibase formatted sql
-- changeset SAMQA:1754373940406 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.external_sales_team_leads.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.external_sales_team_leads.sql:null:076dcdde814c639af1e24937ede48aadb8ea9973:create

grant delete on samqa.external_sales_team_leads to rl_sam_rw;

grant insert on samqa.external_sales_team_leads to rl_sam_rw;

grant select on samqa.external_sales_team_leads to rl_sam1_ro;

grant select on samqa.external_sales_team_leads to rl_sam_rw;

grant select on samqa.external_sales_team_leads to rl_sam_ro;

grant update on samqa.external_sales_team_leads to rl_sam_rw;

