-- liquibase formatted sql
-- changeset SAMQA:1754374164118 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\vendor_class_gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/vendor_class_gp.sql:null:ba6305d9a33420d7ce7e3dd9701b4fa6fda7778d:create

create table samqa.vendor_class_gp (
    vendor_class_id   number,
    vendor_class_code varchar2(100 byte),
    account_type      varchar2(30 byte),
    reason_type       varchar2(30 byte),
    description       varchar2(255 byte),
    currency_code     varchar2(10 byte),
    rate_type_code    varchar2(10 byte),
    tax_schedule      varchar2(20 byte),
    shipping_method   varchar2(30 byte),
    checkbook_id      number,
    user_defined1     varchar2(255 byte),
    user_defined2     varchar2(255 byte),
    tax_type          varchar2(10 byte),
    fob               varchar2(10 byte)
);

alter table samqa.vendor_class_gp
    add constraint vendor_class_gp_p primary key ( vendor_class_id )
        using index enable;

alter table samqa.vendor_class_gp
    add constraint vendor_class_gp_u1
        unique ( vendor_class_code,
                 account_type,
                 reason_type )
            using index enable;

