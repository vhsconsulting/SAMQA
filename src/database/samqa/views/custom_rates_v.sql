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


-- sqlcl_snapshot {"hash":"f7580c0e2f648af5e58bbe4aae3a8dc25808b967","type":"VIEW","name":"CUSTOM_RATES_V","schemaName":"SAMQA","sxml":""}