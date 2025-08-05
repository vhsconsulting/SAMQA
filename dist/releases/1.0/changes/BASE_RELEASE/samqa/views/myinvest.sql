-- liquibase formatted sql
-- changeset SAMQA:1754374177117 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\myinvest.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/myinvest.sql:null:0e736bcec33222841729ad7aeed00f3398f4f23d:create

create or replace force editionable view samqa.myinvest (
    id,
    acc_id,
    invest_id,
    invest_name,
    invest_acc,
    invest_date,
    invest_amount,
    note
) as
    (
        select
            ' ',
            i.acc_id,
            i.invest_id,
            e.name,
            i.invest_acc,
            t.invest_date,
            t.invest_amount,
            t.note
        from
            invest_transfer t,
            investment      i,
            enterprise      e
        where
                t.investment_id = i.investment_id
            and i.invest_id = e.entrp_id
    );

