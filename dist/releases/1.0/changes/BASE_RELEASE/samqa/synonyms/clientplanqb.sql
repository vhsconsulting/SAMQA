-- liquibase formatted sql
-- changeset SAMQA:1754374150496 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientplanqb.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientplanqb.sql:null:88eebaaf677c779f3fdfd71ea6a2d5a7be9abf21:create

create or replace editionable synonym samqa.clientplanqb for cobrap.clientplanqb;

