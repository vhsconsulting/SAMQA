-- liquibase formatted sql
-- changeset SAMQA:1754374150483 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientgroup.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientgroup.sql:null:f55775804d4c21629005025790d8b0d10939bd9a:create

create or replace editionable synonym samqa.clientgroup for cobrap.clientgroup;

