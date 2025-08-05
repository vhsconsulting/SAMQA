-- liquibase formatted sql
-- changeset SAMQA:1754374150575 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\npm_enrollments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/npm_enrollments.sql:null:ca65f8e8bb922d37d1a5da33fdfeb64b438bbf1a:create

create or replace editionable synonym samqa.npm_enrollments for newcobra.npm_enrollments;

