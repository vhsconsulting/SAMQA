-- liquibase formatted sql
-- changeset SAMQA:1754374157057 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\entrp_relationships_staging.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/entrp_relationships_staging.sql:null:ab03d55104ae6a51652970c7bbae0af584caf088:create

create table samqa.entrp_relationships_staging (
    relation_id       number,
    entrp_id          number,
    entity_type       varchar2(30 byte),
    relationship_type varchar2(30 byte),
    status            varchar2(30 byte) default 'A',
    creation_date     date default sysdate,
    created_by        number,
    last_update_date  date default sysdate,
    last_updated_by   number,
    entity_name       varchar2(100 byte),
    batch_number      number
);

