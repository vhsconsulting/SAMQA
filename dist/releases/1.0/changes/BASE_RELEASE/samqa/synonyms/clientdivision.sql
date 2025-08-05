-- liquibase formatted sql
-- changeset SAMQA:1754374150450 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientdivision.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientdivision.sql:null:d6d18400e416e0d0f14200c35c400499c38edb06:create

create or replace editionable synonym samqa.clientdivision for cobrap.clientdivision;

