-- liquibase formatted sql
-- changeset SAMQA:1754374150648 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbdependentplan.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbdependentplan.sql:null:a4b63516e84cb0645cb2646ca5d9500a6b4a6d80:create

create or replace editionable synonym samqa.qbdependentplan for cobrap.qbdependentplan;

