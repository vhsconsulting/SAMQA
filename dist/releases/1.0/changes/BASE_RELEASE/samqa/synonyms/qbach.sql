-- liquibase formatted sql
-- changeset SAMQA:1754374150630 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbach.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbach.sql:null:d581d76c11b95b7c016ea4ea54965fe77e0bd436:create

create or replace editionable synonym samqa.qbach for cobrap.qbach;

