-- liquibase formatted sql
-- changeset SAMQA:1754374150515 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\cobra_balance_register_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/cobra_balance_register_v.sql:null:fcb7492a489d2850cba3dabfe28ee492835fe0c4:create

create or replace editionable synonym samqa.cobra_balance_register_v for newcobra.cobra_balance_register_v;

