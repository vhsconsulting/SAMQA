-- liquibase formatted sql
-- changeset SAMQA:1753779555728 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\metavante_card_balances_n2.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/metavante_card_balances_n2.sql:null:5c879167c8866e5e9073cc0694a0eb2ab641a04a:create

create index samqa.metavante_card_balances_n2 on
    samqa.metavante_card_balances (
        plan_type
    );

