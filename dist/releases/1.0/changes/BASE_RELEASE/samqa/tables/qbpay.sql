-- liquibase formatted sql
-- changeset SAMQA:1754374162460 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\qbpay.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/qbpay.sql:null:47f0c28c8ae8694f5dcb5ffdf44d5a82fdddf79a:create

create table samqa.qbpay (
    acc_id          number(9, 0) not null enable,
    depositdate     date,
    paymentmethod   varchar2(2 byte),
    amount          varchar2(40 byte),
    checknumber     varchar2(255 byte),
    postmarkdate    varchar2(24 byte),
    qbpaymentid     number,
    entereddatetime date
);

