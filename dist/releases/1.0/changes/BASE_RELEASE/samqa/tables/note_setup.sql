-- liquibase formatted sql
-- changeset SAMQA:1754374160988 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\note_setup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/note_setup.sql:null:205b68bb1e23bd8b450c0e7d4e660a2dd76e3d14:create

create table samqa.note_setup (
    page_no       number,
    entity_type   varchar2(100 byte),
    argument_name varchar2(100 byte)
);

