-- liquibase formatted sql
-- changeset SAMQA:1754374150443 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientdivisioincommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientdivisioincommunication.sql:null:a0a0171d72ad442488dadaed22eed0ccf090aca5:create

create or replace editionable synonym samqa.clientdivisioincommunication for cobrap.clientdivisioincommunication;

