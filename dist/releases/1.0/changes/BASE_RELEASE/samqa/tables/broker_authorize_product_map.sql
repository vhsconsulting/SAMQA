-- liquibase formatted sql
-- changeset SAMQA:1754374152613 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\broker_authorize_product_map.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/broker_authorize_product_map.sql:null:d815255f41b74402b26bc2696c4d469bd30d20ef:create

create table samqa.broker_authorize_product_map (
    product_type    varchar2(100 byte),
    permission_type varchar2(100 byte),
    description     varchar2(255 byte),
    nav_code        varchar2(255 byte)
);

