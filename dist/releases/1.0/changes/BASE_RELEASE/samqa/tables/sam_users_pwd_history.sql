-- liquibase formatted sql
-- changeset SAMQA:1754374162960 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\sam_users_pwd_history.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/sam_users_pwd_history.sql:null:3acf2534abbb82f1678874a149145dee8c655787:create

create table samqa.sam_users_pwd_history (
    user_id       number,
    password      varchar2(4000 byte),
    created_by    number,
    creation_date date
);

