-- liquibase formatted sql
-- changeset SAMQA:1754374171315 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\crm_users.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/crm_users.sql:null:1d572f2696ccfae5315a34459bfd1a59006f0438:create

create or replace force editionable view samqa.crm_users (
    "user_name",
    "id",
    full_name,
    "status"
) as
    select
        "user_name",
        "id",
        "first_name"
        || ' '
        || "last_name" as full_name,
        "status"
    from
        "users"@sugarprod;

