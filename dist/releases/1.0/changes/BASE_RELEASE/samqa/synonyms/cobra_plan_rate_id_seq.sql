-- liquibase formatted sql
-- changeset SAMQA:1754374150541 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\cobra_plan_rate_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/cobra_plan_rate_id_seq.sql:null:fea07ae7b1dd558512915381d0fcf5348e928a38:create

create or replace editionable synonym samqa.cobra_plan_rate_id_seq for newcobra.cobra_plan_rate_id_seq;

