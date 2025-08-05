-- liquibase formatted sql
-- changeset SAMQA:1754374150437 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\clientcontact.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/clientcontact.sql:null:caff67a4cd2043c4c461714b0aef07b7be688222:create

create or replace editionable synonym samqa.clientcontact for cobrap.clientcontact;

