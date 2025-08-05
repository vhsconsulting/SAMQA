-- liquibase formatted sql
-- changeset SAMQA:1754374150553 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\memberremittancetotalbypost.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/memberremittancetotalbypost.sql:null:588fa1891d1dcdaef9d80cfd8396d69185f68e6b:create

create or replace editionable synonym samqa.memberremittancetotalbypost for cobrap.memberremittancetotalbypost;

