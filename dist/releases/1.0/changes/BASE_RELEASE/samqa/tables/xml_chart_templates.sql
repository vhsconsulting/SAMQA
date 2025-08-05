-- liquibase formatted sql
-- changeset SAMQA:1754374164394 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\xml_chart_templates.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/xml_chart_templates.sql:null:6fb9e1e953cfa776ad4c65641c3d47d979a18492:create

create table samqa.xml_chart_templates (
    primkey       number(*, 0),
    template_name varchar2(50 byte),
    template_text varchar2(4000 byte)
);

alter table samqa.xml_chart_templates add unique ( primkey )
    using index enable;

alter table samqa.xml_chart_templates add unique ( template_name )
    using index enable;

