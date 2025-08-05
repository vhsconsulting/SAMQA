-- liquibase formatted sql
-- changeset SAMQA:1754374150603 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\npmnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/npmnote.sql:null:91644f3dd213c166bee131a720a0f2d0a2a3cf64:create

create or replace editionable synonym samqa.npmnote for cobrap.npmnote;

