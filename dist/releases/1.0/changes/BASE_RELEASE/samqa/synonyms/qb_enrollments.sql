-- liquibase formatted sql
-- changeset SAMQA:1754374150623 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\qb_enrollments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/qb_enrollments.sql:null:b45775336d621d7c56a28de81bfea7572f67e9d3:create

create or replace editionable synonym samqa.qb_enrollments for newcobra.qb_enrollments;

