-- liquibase formatted sql
-- changeset samqa:1754373926785 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\userip.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/userip.sql:null:4b389327b04390a04d181f1e10e4dd169ef9f7a3:create

comment on table samqa.userip is
    'Try define user name by IP Address';

comment on column samqa.userip.ip_addr is
    'Client IP Address';

comment on column samqa.userip.uname is
    'User name';

