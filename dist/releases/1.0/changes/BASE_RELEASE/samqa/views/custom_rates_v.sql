-- liquibase formatted sql
-- changeset SAMQA:1754374171324 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\custom_rates_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/custom_rates_v.sql:null:f7580c0e2f648af5e58bbe4aae3a8dc25808b967:create

create or replace force editionable view samqa.custom_rates_v (
    acc_num,
    acc_id,
    entrp_id,
    fee_setup,
    fee_maint
) as
    select
        acc_num,
        acc_id,
        entrp_id,
        fee_setup,
        fee_maint
    from
        teamster_v;

