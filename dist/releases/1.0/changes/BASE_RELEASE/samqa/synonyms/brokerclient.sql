-- liquibase formatted sql
-- changeset SAMQA:1754374150390 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\brokerclient.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/brokerclient.sql:null:44d4cdef0f273fd743ff03ce474284a804c6e4c9:create

create or replace editionable synonym samqa.brokerclient for cobrap.brokerclient;

