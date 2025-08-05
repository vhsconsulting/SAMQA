-- liquibase formatted sql
-- changeset SAMQA:1754374150402 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\carriercontact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/carriercontact.sql:null:c121703e5b674d861f81ef6ce8e379cb22017e0f:create

create or replace editionable synonym samqa.carriercontact for cobrap.carriercontact;

