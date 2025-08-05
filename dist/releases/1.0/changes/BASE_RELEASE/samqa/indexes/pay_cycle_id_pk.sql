-- liquibase formatted sql
-- changeset SAMQA:1754373932576 stripComments:false logicalFilePath:BASE_RELEASE\samqa\indexes\pay_cycle_id_pk.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/indexes/pay_cycle_id_pk.sql:null:1f954f9f599a49ff1c70405c7e187fdd88ec8720:create

create unique index samqa.pay_cycle_id_pk on
    samqa.pay_cycle_stage (
        pay_cycle_id
    );

