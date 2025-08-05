-- liquibase formatted sql
-- changeset SAMQA:1754374150396 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\carrier.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/carrier.sql:null:ab6f8c5970fefa97a3d900da4cad3ee86234b183:create

create or replace editionable synonym samqa.carrier for cobrap.carrier;

