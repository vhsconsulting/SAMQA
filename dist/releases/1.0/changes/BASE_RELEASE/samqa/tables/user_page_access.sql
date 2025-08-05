-- liquibase formatted sql
-- changeset SAMQA:1754374163968 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\user_page_access.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/user_page_access.sql:null:127478e44b448eecfd5646777a772e6b9eb5d369:create

create table samqa.user_page_access (
    user_id   number,
    role_type varchar2(250 byte)
);

