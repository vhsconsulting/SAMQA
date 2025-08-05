-- liquibase formatted sql
-- changeset SAMQA:1754374170140 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\close_pay_type.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/close_pay_type.sql:null:a7c9ba363c2148fbb1d0ac524ac89fa7a2ead06c:create

create or replace force editionable view samqa.close_pay_type (
    reason_name,
    reason_code
) as
    select
        reason_name,
        reason_code
    from
        pay_reason
    where
        ( reason_code in ( 12, 120, 80 ) );

