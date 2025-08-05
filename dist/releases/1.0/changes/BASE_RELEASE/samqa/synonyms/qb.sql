-- liquibase formatted sql
-- changeset SAMQA:1754374150616 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qb.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qb.sql:null:40590509010d28a83e0e79a444558f03f5a91640:create

create or replace editionable synonym samqa.qb for cobrap.qb;

