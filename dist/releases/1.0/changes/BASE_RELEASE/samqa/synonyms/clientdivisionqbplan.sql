-- liquibase formatted sql
-- changeset SAMQA:1754374150470 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientdivisionqbplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientdivisionqbplan.sql:null:8b7503f28fa3d4820fafd76e49e283f8fe175488:create

create or replace editionable synonym samqa.clientdivisionqbplan for cobrap.clientdivisionqbplan;

