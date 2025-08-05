-- liquibase formatted sql
-- changeset SAMQA:1754374154436 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\customer_class_gp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/customer_class_gp.sql:null:47f01bf8d21228d628ebaecf2afd3d9e7c88023f:create

create table samqa.customer_class_gp (
    customer_class_id number,
    cust_class_code   varchar2(100 byte),
    account_type      varchar2(30 byte),
    reason_type       varchar2(30 byte),
    description       varchar2(255 byte),
    currency_code     varchar2(10 byte),
    rate_type_code    varchar2(30 byte),
    payment_terms     varchar2(30 byte),
    tax_schedule      varchar2(20 byte),
    shipping_method   varchar2(20 byte),
    checkbook_id      number,
    user_defined1     varchar2(255 byte),
    user_defined2     varchar2(255 byte)
);

alter table samqa.customer_class_gp
    add constraint customer_class_gp_p primary key ( customer_class_id )
        using index enable;

alter table samqa.customer_class_gp
    add constraint customer_class_gp_u1
        unique ( cust_class_code,
                 account_type,
                 reason_type )
            using index enable;

