-- liquibase formatted sql
-- changeset SAMQA:1754373937769 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.sequence.external_sales_team_lead_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.sequence.external_sales_team_lead_seq.sql:null:88d0bad39d41655d053f56f09885d38c4d86463c:create

grant select on samqa.external_sales_team_lead_seq to rl_sam_rw;

