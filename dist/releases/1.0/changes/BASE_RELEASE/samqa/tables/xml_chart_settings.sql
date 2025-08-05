-- liquibase formatted sql
-- changeset SAMQA:1754374164375 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\xml_chart_settings.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/xml_chart_settings.sql:null:2c22f426b2419c6510de2ff5824c810fec18f33d:create

create table samqa.xml_chart_settings (
    primkey       number(*, 0),
    cat_name      varchar2(50 byte),
    setting_name  varchar2(50 byte),
    setting_value varchar2(50 byte),
    chart_type    varchar2(400 byte)
);

alter table samqa.xml_chart_settings add unique ( primkey )
    using index enable;

