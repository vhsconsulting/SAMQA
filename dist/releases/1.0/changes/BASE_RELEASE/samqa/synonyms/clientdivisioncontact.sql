-- liquibase formatted sql
-- changeset SAMQA:1754374150457 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientdivisioncontact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientdivisioncontact.sql:null:609ff9709bd41b28543cc479c957d798e35f31eb:create

create or replace editionable synonym samqa.clientdivisioncontact for cobrap.clientdivisioncontact;

