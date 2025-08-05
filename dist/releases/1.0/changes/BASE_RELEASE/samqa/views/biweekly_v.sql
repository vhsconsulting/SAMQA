-- liquibase formatted sql
-- changeset SAMQA:1754374168738 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\biweekly_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/biweekly_v.sql:null:2f56c8866e4142d986a58a086f3b52c07e7dace2:create

create or replace force editionable view samqa.biweekly_v (
    period_date
) as
    with data as (
        select
            2 * level k
        from
            dual
        connect by
            level <= 26
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

