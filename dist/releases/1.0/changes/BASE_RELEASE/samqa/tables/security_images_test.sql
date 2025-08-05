-- liquibase formatted sql
-- changeset SAMQA:1754374163168 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\security_images_test.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/security_images_test.sql:null:63c5543ed21b1b26ff7541af5cda94cdbf57ef4d:create

create table samqa.security_images_test (
    security_image_id number not null enable,
    security_image    blob,
    description       varchar2(1000 byte),
    creation_date     date,
    created_by        number,
    last_update_date  date,
    last_updated_by   number
);

