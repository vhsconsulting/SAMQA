-- liquibase formatted sql
-- changeset SAMQA:1754374150655 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qbdisabilityinformation.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qbdisabilityinformation.sql:null:36a6f01b5fd995a17a6cf08ee4b208876b86a98c:create

create or replace editionable synonym samqa.qbdisabilityinformation for cobrap.qbdisabilityinformation;

