-- liquibase formatted sql
-- changeset SAMQA:1754374155645 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\department.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/department.sql:null:4f512ddae199f34ea99851480db7bbd0d538ab31:create

create table samqa.department (
    dept_no          number,
    dept_code        varchar2(20 byte),
    dept_name        varchar2(100 byte),
    creation_date    date,
    created_by       number,
    last_update_date date,
    last_updated_by  number
);

alter table samqa.department add primary key ( dept_no )
    using index enable;

