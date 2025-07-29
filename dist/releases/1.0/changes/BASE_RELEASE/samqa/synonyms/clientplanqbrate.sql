-- liquibase formatted sql
-- changeset SAMQA:1753779763548 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientplanqbrate.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientplanqbrate.sql:null:ea3f9d909d678ca5a7ef1ef3b863f45d94851826:create

create or replace editionable synonym samqa.clientplanqbrate for cobrap.clientplanqbrate;

