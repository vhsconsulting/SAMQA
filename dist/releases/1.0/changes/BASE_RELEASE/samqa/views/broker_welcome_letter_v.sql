-- liquibase formatted sql
-- changeset SAMQA:1754374169467 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\broker_welcome_letter_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/broker_welcome_letter_v.sql:null:548ba48b00f1539ab9b9788ab9590d63a8d10278:create

create or replace force editionable view samqa.broker_welcome_letter_v (
    broker_id,
    today,
    broker_name,
    address,
    city,
    start_date
) as
    select
        broker_id,
        to_char(sysdate, 'MM/DD/YYYY') today,
        b.first_name
        || ' '
        || b.middle_name
        || ' '
        || b.last_name                 broker_name,
        b.address                      address,
        b.city
        || ' '
        || b.state
        || ' '
        || b.zip                       city,
        trunc(a.creation_date)         start_date
    from
        broker a,
        person b
    where
            a.broker_id = b.pers_id
        and a.end_date is null
    order by
        b.first_name
        || ' '
        || b.middle_name
        || ' '
        || b.last_name;

