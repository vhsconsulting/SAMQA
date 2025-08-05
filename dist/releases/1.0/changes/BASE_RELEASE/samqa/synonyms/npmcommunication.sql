-- liquibase formatted sql
-- changeset SAMQA:1754374150581 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\npmcommunication.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/npmcommunication.sql:null:3ce4de2369bddc7d0086dd0aff4c88db221e2910:create

create or replace editionable synonym samqa.npmcommunication for cobrap.npmcommunication;

