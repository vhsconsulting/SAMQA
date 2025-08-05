-- liquibase formatted sql
-- changeset SAMQA:1754373939539 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.contact_leads.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.contact_leads.sql:null:d7d1cb3ee77b5e710e1b1b0d992c1c63f05ba4d9:create

grant delete on samqa.contact_leads to rl_sam_rw;

grant insert on samqa.contact_leads to rl_sam_rw;

grant select on samqa.contact_leads to rl_sam1_ro;

grant select on samqa.contact_leads to rl_sam_rw;

grant select on samqa.contact_leads to rl_sam_ro;

grant update on samqa.contact_leads to rl_sam_rw;

