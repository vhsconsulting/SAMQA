-- liquibase formatted sql
-- changeset SAMQA:1754374150636 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbcommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbcommunication.sql:null:43cb66315e1586b9f96c93d73055fe15a159765c:create

create or replace editionable synonym samqa.qbcommunication for cobrap.qbcommunication;

