-- liquibase formatted sql
-- changeset SAMQA:1754374150424 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\client.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/client.sql:null:0136d27e8ac4415659a7219dfd25d2b10def7323:create

create or replace editionable synonym samqa.client for cobrap.client;

