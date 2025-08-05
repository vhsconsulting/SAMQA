-- liquibase formatted sql
-- changeset SAMQA:1754374163136 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\security_images.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/security_images.sql:null:c304c01d2e9c9c22676acf25887f2e349100d12a:create

create table samqa.security_images (
    security_image_id number,
    security_image    blob,
    description       varchar2(1000 byte),
    creation_date     date default sysdate,
    created_by        number,
    last_update_date  date default sysdate,
    last_updated_by   number
);

create unique index samqa.security_images_u1 on
    samqa.security_images (
        security_image_id
    );

alter table samqa.security_images
    add
        primary key ( security_image_id )
            using index samqa.security_images_u1 enable;

