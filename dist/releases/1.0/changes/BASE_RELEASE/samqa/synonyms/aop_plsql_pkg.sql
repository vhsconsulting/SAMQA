-- liquibase formatted sql
-- changeset SAMQA:1754374150383 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\aop_plsql_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/aop_plsql_pkg.sql:null:1aef256a918e352caf735785a5b21fc912b61864:create

create or replace editionable synonym samqa.aop_plsql_pkg for samqa.aop_plsql22_pkg;

