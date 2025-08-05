-- liquibase formatted sql
-- changeset SAMQA:1754374150642 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbdependent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbdependent.sql:null:7f5ffce070d411d8d1b9512b82cca5fe3924b037:create

create or replace editionable synonym samqa.qbdependent for cobrap.qbdependent;

