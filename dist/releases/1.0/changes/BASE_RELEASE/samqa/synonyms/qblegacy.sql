-- liquibase formatted sql
-- changeset SAMQA:1754374150669 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qblegacy.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qblegacy.sql:null:61c9d64ff09881810480e14269c56dba113b0857:create

create or replace editionable synonym samqa.qblegacy for cobrap.qblegacy;

