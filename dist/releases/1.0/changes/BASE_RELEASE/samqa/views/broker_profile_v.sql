-- liquibase formatted sql
-- changeset SAMQA:1754374169086 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\broker_profile_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/broker_profile_v.sql:null:8a26c54f57c36734af864478491c66e9b018814f:create

create or replace force editionable view samqa.broker_profile_v (
    broker_id,
    broker_lic,
    name,
    address,
    city,
    state,
    zip,
    agency_name,
    phone_day,
    email,
    user_name,
    user_id
) as
    select
        a.broker_id,
        a.broker_lic,
        b.first_name
        || ' '
        || b.last_name name,
        b.address,
        b.city,
        b.state,
        b.zip,
        a.agency_name,
        b.phone_day,
        b.email,
        c.user_name,
        c.user_id
    from
        broker       a,
        person       b,
        online_users c
    where
            a.broker_id = b.pers_id
        and c.find_key = a.broker_lic
        and c.user_type = 'B';

