-- liquibase formatted sql
-- changeset SAMQA:1754374150464 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientdivisionnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientdivisionnote.sql:null:433a71a7ab14e4c13727c222a7ddfe06a2e146c6:create

create or replace editionable synonym samqa.clientdivisionnote for cobrap.clientdivisionnote;

