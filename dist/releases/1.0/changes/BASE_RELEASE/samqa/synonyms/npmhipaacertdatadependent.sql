-- liquibase formatted sql
-- changeset SAMQA:1754374150597 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\npmhipaacertdatadependent.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/npmhipaacertdatadependent.sql:null:4ab74c7f6bfc035eb22d2e63a7b4088d08713082:create

create or replace editionable synonym samqa.npmhipaacertdatadependent for cobrap.npmhipaacertdatadependent;

