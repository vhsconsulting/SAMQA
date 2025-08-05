-- liquibase formatted sql
-- changeset SAMQA:1754374150568 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\npm.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/npm.sql:null:5a5e70646d9d022c9f90661ced5ba978bcb9e400:create

create or replace editionable synonym samqa.npm for cobrap.npm;

