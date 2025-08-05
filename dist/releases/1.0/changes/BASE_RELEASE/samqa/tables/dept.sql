-- liquibase formatted sql
-- changeset SAMQA:1754374155721 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\dept.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/dept.sql:null:352bd6e30961fed87871bb3b972adce693d10bb2:create

create table samqa.dept (
    deptno number(2, 0),
    dname  varchar2(14 byte),
    loc    varchar2(13 byte)
);

alter table samqa.dept add primary key ( deptno )
    using index enable;

