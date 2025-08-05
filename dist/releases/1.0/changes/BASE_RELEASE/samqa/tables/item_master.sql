-- liquibase formatted sql
-- changeset SAMQA:1754374159929 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\item_master.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/item_master.sql:null:bb545060988c1b05b87e0a1305da28474bd2ec2a:create

create table samqa.item_master (
    item_master_id                 number,
    item_number                    varchar2(30 byte),
    item_description               varchar2(1000 byte),
    item_short_name                varchar2(30 byte),
    item_generic_description       varchar2(1000 byte),
    item_class_id                  number,
    item_type                      varchar2(30 byte),
    valuation_method               varchar2(30 byte),
    item_shipping_weight           varchar2(30 byte),
    sales_tax_options              varchar2(30 byte),
    sales_tax_schedule_id          varchar2(30 byte),
    uom                            varchar2(10 byte),
    purchase_tax_options           varchar2(30 byte),
    purchase_tax_schedule_id       varchar2(35 byte),
    standard_cost                  number,
    current_cost                   number,
    list_price                     number,
    quantity                       number,
    currency_code                  varchar2(10 byte),
    note                           varchar2(4000 byte),
    inventory_gl_acct              varchar2(80 byte),
    inventory_offset_gl_acct       varchar2(80 byte),
    cost_of_goods_sold_gl_acct     varchar2(80 byte),
    sales_gl_acct                  varchar2(80 byte),
    markdowns_gl_acct              varchar2(80 byte),
    sales_returns_gl_acct          varchar2(80 byte),
    in_use_gl_acct                 varchar2(80 byte),
    in_service_gl_acct             varchar2(80 byte),
    damaged_gl_acct                varchar2(80 byte),
    variance_gl_acct               varchar2(80 byte),
    drop_ship_items_gl_acct        varchar2(80 byte),
    prchs_price_variance_gl_acct   varchar2(80 byte),
    unrelzd_prchs_prc_vrnc_gl_acct varchar2(80 byte),
    inventory_return_gl_acct       varchar2(80 byte),
    assembly_variance_gl_acct      varchar2(80 byte)
);

alter table samqa.item_master
    add constraint item_master_p primary key ( item_master_id )
        using index enable;

alter table samqa.item_master add constraint item_master_u1 unique ( item_number )
    using index enable;

