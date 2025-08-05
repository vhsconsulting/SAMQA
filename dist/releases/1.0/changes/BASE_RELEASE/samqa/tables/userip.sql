-- liquibase formatted sql
-- changeset SAMQA:1754374164035 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\userip.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/userip.sql:null:29d19b8343204a04234acefa2c6e43ad4ede771c:create

create table samqa.userip (
    ip_addr varchar2(30 byte),
    uname   varchar2(30 byte) not null enable
);

create unique index samqa.userip_pk on
    samqa.userip (
        ip_addr
    );

alter table samqa.userip
    add constraint userip_pk
        primary key ( ip_addr )
            using index samqa.userip_pk enable;

