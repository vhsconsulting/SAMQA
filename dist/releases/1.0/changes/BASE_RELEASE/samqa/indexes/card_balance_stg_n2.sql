-- liquibase formatted sql
-- changeset SAMQA:1754373929944 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\card_balance_stg_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/card_balance_stg_n2.sql:null:6478a4ca6d60c9a3e803c53dfc80b76ea4015919:create

create index samqa.card_balance_stg_n2 on
    samqa.card_balance_stg (
        plan_type
    );

