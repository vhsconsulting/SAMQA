-- liquibase formatted sql
-- changeset SAMQA:1754374150370 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\aop_api_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/aop_api_pkg.sql:null:c93a1009fd5583cd1289681cfb0d171cc3613807:create

create or replace editionable synonym samqa.aop_api_pkg for samqa.aop_api22_pkg;

