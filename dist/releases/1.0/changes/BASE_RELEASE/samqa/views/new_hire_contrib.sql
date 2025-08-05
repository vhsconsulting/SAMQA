-- liquibase formatted sql
-- changeset SAMQA:1754374177566 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\new_hire_contrib.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/new_hire_contrib.sql:null:33b1a0f7b62ed92371ad7146ae9e2320e6f60104:create

create or replace force editionable view samqa.new_hire_contrib (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'NEW_HIRE_CONTRIB';

