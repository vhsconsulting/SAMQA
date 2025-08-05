-- liquibase formatted sql
-- changeset SAMQA:1754374159867 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\item_class.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/item_class.sql:null:2294d4894bd104339e925b2d12076e529429936f:create

create table samqa.item_class (
    item_class_id       number,
    item_class_code     varchar2(30 byte),
    description         varchar2(255 byte),
    currency_code       varchar2(30 byte),
    item_type           varchar2(100 byte),
    sales_tax_option    varchar2(100 byte),
    quantity            number,
    uom                 varchar2(30 byte),
    price_group         varchar2(255 byte),
    default_price_level varchar2(255 byte)
);

alter table samqa.item_class
    add constraint item_class_p primary key ( item_class_id )
        using index enable;

