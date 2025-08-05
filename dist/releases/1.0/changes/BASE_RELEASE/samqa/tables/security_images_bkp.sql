-- liquibase formatted sql
-- changeset SAMQA:1754374163152 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\security_images_bkp.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/security_images_bkp.sql:null:93b2da7368f8e156f8dbf0d2d9acfbe7d2fb9405:create

create table samqa.security_images_bkp (
    security_image_id number,
    security_image    blob,
    description       varchar2(1000 byte),
    creation_date     date,
    created_by        number,
    last_update_date  date,
    last_updated_by   number
);

