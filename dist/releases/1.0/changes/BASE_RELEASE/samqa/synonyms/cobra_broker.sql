-- liquibase formatted sql
-- changeset SAMQA:1754374150521 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\cobra_broker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/cobra_broker.sql:null:4e4ba8879141f95d5ba43a40c1eac89b09d25f30:create

create or replace editionable synonym samqa.cobra_broker for cobrap.broker;

