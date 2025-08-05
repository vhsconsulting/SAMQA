-- liquibase formatted sql
-- changeset SAMQA:1754374154233 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\crm_interfaces.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/crm_interfaces.sql:null:137530edd5860856dce8837306ae6a10573c0a19:create

create table samqa.crm_interfaces (
    interface_id     number,
    entity_name      varchar2(255 byte),
    entity_id        varchar2(255 byte),
    interface_status varchar2(255 byte),
    creation_date    date default sysdate,
    interfaced_id    varchar2(255 byte)
);

alter table samqa.crm_interfaces add primary key ( interface_id )
    using index enable;

