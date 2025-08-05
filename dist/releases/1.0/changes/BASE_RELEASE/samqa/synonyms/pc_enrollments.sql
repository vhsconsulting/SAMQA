-- liquibase formatted sql
-- changeset SAMQA:1754374150610 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\pc_enrollments.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/pc_enrollments.sql:null:de11050ffab85b17acf9164e309f6c5aa2de9e2c:create

create or replace editionable synonym samqa.pc_enrollments for newcobra.pc_enrollments;

