-- liquibase formatted sql
-- changeset SAMQA:1754374150502 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientplanqbnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientplanqbnote.sql:null:91106e8e702a07e00722aa28dea8666284616285:create

create or replace editionable synonym samqa.clientplanqbnote for cobrap.clientplanqbnote;

