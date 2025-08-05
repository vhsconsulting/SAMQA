-- liquibase formatted sql
-- changeset SAMQA:1754374150418 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\carriernotification.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/carriernotification.sql:null:18061c6a4a7849c014fc2819507dc741f5b15fea:create

create or replace editionable synonym samqa.carriernotification for cobrap.carriernotification;

