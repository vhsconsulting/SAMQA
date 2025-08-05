-- liquibase formatted sql
-- changeset SAMQA:1754374162928 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sam_roles.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sam_roles.sql:null:a0054617d12cd265c4b196bc3d95429d78120df5:create

create table samqa.sam_roles (
    role_id          number,
    role_name        varchar2(90 byte),
    role_description varchar2(21 byte),
    note             varchar2(4000 byte)
);

