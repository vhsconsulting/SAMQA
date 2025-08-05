-- liquibase formatted sql
-- changeset SAMQA:1754374151847 stripComments:false logicalFilePath:BASE_RELEASE\samqa\tables\balance_gt.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/tables/balance_gt.sql:null:f9753aa96b8b8a2bd172bf473b8ab3d21ad882f2:create

create global temporary table samqa.balance_gt (
    balance  number,
    acc_id   number(9, 0) not null enable,
    interest number
) on commit preserve rows;

