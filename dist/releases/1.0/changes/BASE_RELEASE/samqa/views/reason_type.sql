-- liquibase formatted sql
-- changeset SAMQA:1754374178471 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\reason_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/reason_type.sql:null:e3060f10ddf6573c060a6f6f28b69d547159c634:create

create or replace force editionable view samqa.reason_type (
    lookup_code,
    meaning
) as
    select
        lookup_code,
        meaning
    from
        lookups
    where
        lookup_name = 'REASON_TYPE';

