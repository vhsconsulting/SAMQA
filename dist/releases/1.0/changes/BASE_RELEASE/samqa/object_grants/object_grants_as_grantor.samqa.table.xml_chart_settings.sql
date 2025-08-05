-- liquibase formatted sql
-- changeset SAMQA:1754373942548 stripComments:false logicalFilePath:BASE_RELEASE\samqa\object_grants\object_grants_as_grantor.samqa.table.xml_chart_settings.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/object_grants/object_grants_as_grantor.samqa.table.xml_chart_settings.sql:null:18afa0ef95d6aa27e456222b931a32aa2e85a0a4:create

grant delete on samqa.xml_chart_settings to rl_sam_rw;

grant insert on samqa.xml_chart_settings to rl_sam_rw;

grant select on samqa.xml_chart_settings to rl_sam1_ro;

grant select on samqa.xml_chart_settings to rl_sam_rw;

grant select on samqa.xml_chart_settings to rl_sam_ro;

grant update on samqa.xml_chart_settings to rl_sam_rw;

