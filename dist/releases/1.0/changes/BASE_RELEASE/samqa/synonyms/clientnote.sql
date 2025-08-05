-- liquibase formatted sql
-- changeset SAMQA:1754374150489 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientnote.sql:null:acb3ae40347ba396dd461c560731ab8a3b8c9982:create

create or replace editionable synonym samqa.clientnote for cobrap.clientnote;

