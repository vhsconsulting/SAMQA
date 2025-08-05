-- liquibase formatted sql
-- changeset SAMQA:1754374150547 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\get_rate_lines.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/get_rate_lines.sql:null:4c49b0c203a183942fa4fc864b8fed93e64da4a2:create

create or replace editionable synonym samqa.get_rate_lines for cobra.get_rate_lines;

