-- liquibase formatted sql
-- changeset SAMQA:1754374150689 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbplan.sql:null:51aa6e76f931bbc32a8b29bb85e7894caced6c29:create

create or replace editionable synonym samqa.qbplan for cobrap.qbplan;

