-- liquibase formatted sql
-- changeset SAMQA:1754374178463 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\quarterly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/quarterly_v.sql:null:11102090efc584cbe59db2d8111138869590461b:create

create or replace force editionable view samqa.quarterly_v (
    rn,
    period_date
) as
    select
        rownum rn,
        add_months(
            trunc(sysdate, 'yyyy'),
            rownum * 3
        )      period_date
    from
        all_objects
    where
        rownum <= 4;

