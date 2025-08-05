-- liquibase formatted sql
-- changeset SAMQA:1754374151395 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\agvc.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/agvc.sql:null:63a47853f47dadd73bbf93d654146732983f9046:create

create table samqa.agvc (
    low    number,
    age    varchar2(20 byte),
    male   number,
    female number,
    na     number,
    total  number
);

