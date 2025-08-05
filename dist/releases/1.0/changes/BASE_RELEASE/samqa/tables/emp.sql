-- liquibase formatted sql
-- changeset SAMQA:1754374155888 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\emp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/emp.sql:null:cc0ae93fb1a766c2ec9206f33204cd96e671e742:create

create table samqa.emp (
    empno    number(4, 0) not null enable,
    ename    varchar2(10 byte),
    job      varchar2(9 byte),
    mgr      number(4, 0),
    hiredate date,
    sal      number(7, 2),
    comm     number(7, 2),
    deptno   number(2, 0)
);

alter table samqa.emp add primary key ( empno )
    using index enable;

