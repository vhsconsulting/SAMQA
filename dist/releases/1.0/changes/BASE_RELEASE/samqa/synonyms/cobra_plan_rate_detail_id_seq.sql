-- liquibase formatted sql
-- changeset SAMQA:1754374150534 stripComments:false logicalFilePath:BASE_RELEASE\samqa\synonyms\cobra_plan_rate_detail_id_seq.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/synonyms/cobra_plan_rate_detail_id_seq.sql:null:f7fbc629da45631aedcd80194bbada2bde30be04:create

create or replace editionable synonym samqa.cobra_plan_rate_detail_id_seq for newcobra.cobra_plan_rate_detail_id_seq;

