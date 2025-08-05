-- liquibase formatted sql
-- changeset SAMQA:1754374150376 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\aop_convert_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/aop_convert_pkg.sql:null:55f4ba37cc944a9edf24dfb8cae2f26bf522499d:create

create or replace editionable synonym samqa.aop_convert_pkg for samqa.aop_convert22_pkg;

