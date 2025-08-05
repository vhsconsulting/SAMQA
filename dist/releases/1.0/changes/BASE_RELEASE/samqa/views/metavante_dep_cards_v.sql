-- liquibase formatted sql
-- changeset SAMQA:1754374176842 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\metavante_dep_cards_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/metavante_dep_cards_v.sql:null:dcc76e2987b751cb983caef0108a409b4ea15339:create

create or replace force editionable view samqa.metavante_dep_cards_v (
    dependant_id,
    status_code
) as
    with cards as (
        select
            dependant_id,
            sum(
                case
                    when status_code = 2 then
                        3
                    else
                        0
                end
            ) active_count,
            sum(
                case
                    when status_code = 1 then
                        3
                    else
                        0
                end
            ) new_count,
            sum(
                case
                    when status_code = 3 then
                        3
                    else
                        0
                end
            ) suspended_count,
            sum(
                case
                    when status_code = 4 then
                        1
                    else
                        0
                end
            ) closed_count,
            sum(
                case
                    when status_code = 5 then
                        1
                    else
                        0
                end
            ) lost_stolen_count
        from
            cards_external
        where
            dependant_id is not null
            and is_number(dependant_id) = 'Y'
        group by
            dependant_id
    )
    select
        dependant_id,
        1 status_code
    from
        cards
    where
            new_count > 0
        and active_count = 0
        and suspended_count = 0
        and closed_count >= 0
    union
    select
        dependant_id,
        2 status_code
    from
        cards
    where
            active_count > 0
        and new_count = 0
        and suspended_count = 0
        and closed_count >= 0
    union
    select
        dependant_id,
        3 status_code
    from
        cards
    where
            active_count = 0
        and new_count = 0
        and suspended_count > 0
        and closed_count = 0
    union
    select
        dependant_id,
        4 status_code
    from
        cards
    where
            active_count = 0
        and suspended_count = 0
        and new_count = 0
        and closed_count > 0
        and lost_stolen_count = 0
    union
    select
        dependant_id,
        5 status_code
    from
        cards
    where
            active_count = 0
        and new_count = 0
        and suspended_count = 0
        and closed_count >= 0
        and lost_stolen_count > 0;

