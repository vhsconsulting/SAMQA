-- liquibase formatted sql
-- changeset SAMQA:1754374150661 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbevent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbevent.sql:null:d30984424bcc568b2b0e018aa8228f25de3a9595:create

create or replace editionable synonym samqa.qbevent for cobrap.qbevent;

