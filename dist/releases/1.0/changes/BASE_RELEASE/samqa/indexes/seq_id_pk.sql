-- liquibase formatted sql
-- changeset SAMQA:1754373933368 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\seq_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/seq_id_pk.sql:null:a4dd0d65ac9f69973e68bbde1c9492cb799ee22c:create

create unique index samqa.seq_id_pk on
    samqa.benefit_codes_stage (
        seq_id
    );

