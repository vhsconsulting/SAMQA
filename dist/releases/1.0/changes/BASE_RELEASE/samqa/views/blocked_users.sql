-- liquibase formatted sql
-- changeset SAMQA:1754374168746 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\blocked_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/blocked_users.sql:null:19fddb85ee0e8a0a6f5ec256c96f41cf8df4e1c5:create

create or replace force editionable view samqa.blocked_users (
    user_name,
    find_key
) as
    select
        user_name,
        find_key
    from
        online_users
    where
        blocked = 'Y';

