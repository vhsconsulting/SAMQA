-- liquibase formatted sql
-- changeset SAMQA:1754374163342 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\ssl_domain_cert.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/ssl_domain_cert.sql:null:ea378eb7ee5b3e3fbec8839671461241ad01515e:create

create table samqa.ssl_domain_cert (
    ssl_certificate_name varchar2(255 byte),
    order_number         varchar2(255 byte),
    expiration_date      date,
    thawte_user_name     varchar2(255 byte),
    thaete_password      varchar2(255 byte),
    csr                  varchar2(4000 byte),
    domain_name          varchar2(4000 byte)
);

