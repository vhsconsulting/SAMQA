-- liquibase formatted sql
-- changeset SAMQA:1754374160546 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\message.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/message.sql:null:71ec3f56d722c4a88bc971d1050b2ef98145c88c:create

create table samqa.message (
    text varchar2(4000 byte)
);

