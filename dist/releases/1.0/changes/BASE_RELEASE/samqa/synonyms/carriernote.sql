-- liquibase formatted sql
-- changeset SAMQA:1754374150411 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\carriernote.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/carriernote.sql:null:b40c9797d5e01a75fc3b2a5ddb0e4eee455038a9:create

create or replace editionable synonym samqa.carriernote for cobrap.carriernote;

