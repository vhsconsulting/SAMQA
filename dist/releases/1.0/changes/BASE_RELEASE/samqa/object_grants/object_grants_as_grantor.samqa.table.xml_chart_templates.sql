-- liquibase formatted sql
-- changeset SAMQA:1754373942555 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.xml_chart_templates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.xml_chart_templates.sql:null:237ed058bfbe1660eb9a86cef3a62ab77fb6d0be:create

grant delete on samqa.xml_chart_templates to rl_sam_rw;

grant insert on samqa.xml_chart_templates to rl_sam_rw;

grant select on samqa.xml_chart_templates to rl_sam1_ro;

grant select on samqa.xml_chart_templates to rl_sam_rw;

grant select on samqa.xml_chart_templates to rl_sam_ro;

grant update on samqa.xml_chart_templates to rl_sam_rw;

