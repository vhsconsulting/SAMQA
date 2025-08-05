-- liquibase formatted sql
-- changeset SAMQA:1754374157023 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\entrp_relationships.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/entrp_relationships.sql:null:d2eb1b7c1cd2b9ac1842bcf372dd1eabe3cfe76b:create

create table samqa.entrp_relationships (
    relationship_id   number,
    entrp_id          number,
    tax_id            varchar2(30 byte),
    entity_id         varchar2(30 byte),
    entity_type       varchar2(30 byte),
    relationship_type varchar2(30 byte),
    start_date        date default sysdate,
    end_date          date,
    status            varchar2(30 byte) default 'A',
    note              varchar2(3200 byte),
    creation_date     date default sysdate,
    created_by        number,
    last_update_date  date default sysdate,
    last_updated_by   number
);

alter table samqa.entrp_relationships add primary key ( relationship_id )
    using index enable;

