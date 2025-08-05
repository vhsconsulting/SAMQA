-- liquibase formatted sql
-- changeset SAMQA:1754374176999 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\mybroker.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/mybroker.sql:null:242a9e8453d274babdc24072e5ccb58a3279e103:create

create or replace force editionable view samqa.mybroker (
    broker_id,
    broker_lic,
    start_date,
    end_date,
    title,
    first_name,
    middle_name,
    last_name,
    address,
    city,
    state,
    zip,
    name,
    broker_rate,
    broker_phone,
    broker_email,
    term,
    ga_id,
    agency_name
) as
    (
        select
            b.broker_id,
            nvl(b.broker_lic, 'SK' || b.broker_id) as broker_lic,
            b.start_date,
            b.end_date,
            rtrim(p.title, '.')                    as title,
            p.first_name,
            p.middle_name,
            p.last_name,
            p.address,
            p.city,
            p.state,
            p.zip,
            e.name,
            b.broker_rate / 100                    as broker_rate,
            substr(phone_day, 1, 30),
            substr(email, 1, 50),
            null                                   as term,
            ga_id                                  general_agent,
            b.agency_name
        from
            broker     b,
            person     p,
            enterprise e
        where
                b.broker_id = p.pers_id
            and b.broker_id > 0                        -- omit service person
            and p.entrp_id = e.entrp_id (+)
    );

