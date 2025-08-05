-- liquibase formatted sql
-- changeset SAMQA:1754374150676 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbnote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbnote.sql:null:d3649266ec01b9704c85ad3f6dc74d1db26e183e:create

create or replace editionable synonym samqa.qbnote for cobrap.qbnote;

