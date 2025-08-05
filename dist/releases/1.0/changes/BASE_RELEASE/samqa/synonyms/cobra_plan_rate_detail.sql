-- liquibase formatted sql
-- changeset SAMQA:1754374150528 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\cobra_plan_rate_detail.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/cobra_plan_rate_detail.sql:null:07e25891b93c94f2a7fcbe0f8eb394dde8ffba23:create

create or replace editionable synonym samqa.cobra_plan_rate_detail for newcobra.cobra_plan_rate_detail;

