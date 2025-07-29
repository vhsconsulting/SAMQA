create or replace force editionable view samqa.temp_metavante_cards_v (
    employee_id,
    status_code
) as
    with cards as (
        select
            employee_id,
            sum(
                case
                    when status_code = 2 then
                        1
                    else
                        0
                end
            ) active_count,
            sum(
                case
                    when status_code = 1 then
                        1
                    else
                        0
                end
            ) new_count,
            sum(
                case
                    when status_code = 3 then
                        1
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
            dependant_id is null
        group by
            employee_id
    )
    select
        employee_id,
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
        employee_id,
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
        employee_id,
        2 status_code
    from
        cards
    where
            active_count > 0
        and new_count > 0
        and suspended_count = 0
        and closed_count = 0
    union
    select
        employee_id,
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
        employee_id,
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
        employee_id,
        4 status_code
    from
        cards
    where
            active_count = 0
        and suspended_count = 0
        and new_count = 0
        and closed_count > 0
        and lost_stolen_count >= 0
    union
    select
        employee_id,
        5 status_code
    from
        cards
    where
            active_count = 0
        and new_count = 0
        and suspended_count = 0
        and closed_count >= 0
        and lost_stolen_count > 0;


-- sqlcl_snapshot {"hash":"2e27e734420ca068bb7fa9dd9a4c7db4a5f9b81d","type":"VIEW","name":"TEMP_METAVANTE_CARDS_V","schemaName":"SAMQA","sxml":""}