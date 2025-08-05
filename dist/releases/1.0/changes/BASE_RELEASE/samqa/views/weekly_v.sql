-- liquibase formatted sql
-- changeset SAMQA:1754374180193 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\weekly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/weekly_v.sql:null:2233635dfc2183f20c2f6db45c0460d83a40de49:create

create or replace force editionable view samqa.weekly_v (
    period_date
) as
    with data as (
        select
            level - 1 k
        from
            dual
        connect by
            level <= 52
    )
    select
        add_weeks(
            trunc(sysdate, 'yyyy'),
            k
        ) period_date
    from
        data
    order by
        1;

