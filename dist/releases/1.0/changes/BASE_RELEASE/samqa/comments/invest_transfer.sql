-- liquibase formatted sql
-- changeset samqa:1754373926634 stripComments:false logicalFilePath:BASE_RELEASE\samqa\comments\invest_transfer.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/comments/invest_transfer.sql:null:b4904ef9ae3916b0268b1ffd3c4824b741750ea0:create

comment on table samqa.invest_transfer is
    'Transfers to and from Investment company';

comment on column samqa.invest_transfer.investment_id is
    'Investment ID';

comment on column samqa.invest_transfer.invest_amount is
    'Outside Investment Transfer amount or Market Value';

comment on column samqa.invest_transfer.invest_code is
    'Code';

comment on column samqa.invest_transfer.invest_date is
    'Transfer date';

comment on column samqa.invest_transfer.note is
    'Any useful remarks';

comment on column samqa.invest_transfer.transfer_id is
    'Primary key';

