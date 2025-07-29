create or replace force editionable view samqa.ee_portfolio_summary_v (
    ssn,
    hsa_find_key,
    hra_find_key,
    fsa_find_key,
    hsa_acc_id,
    hra_acc_id,
    fsa_acc_id
) as
    select
        replace(ssn, '-') ssn,
        max(
            case
                when account_type = 'HSA' then
                    acc_num
                else
                    null
            end
        )                 hsa_find_key,
        max(
            case
                when account_type = 'HRA' then
                    acc_num
                else
                    null
            end
        )                 hra_find_key,
        max(
            case
                when account_type = 'FSA' then
                    acc_num
                else
                    null
            end
        )                 fsa_find_key,
        max(
            case
                when account_type = 'HSA' then
                    acc_id
                else
                    null
            end
        )                 hsa_acc_id,
        max(
            case
                when account_type = 'HRA' then
                    acc_id
                else
                    null
            end
        )                 hra_acc_id,
        max(
            case
                when account_type = 'FSA' then
                    acc_id
                else
                    null
            end
        )                 fsa_acc_id
    from
        acc_overview_v
    where
        account_status <> 4
    group by
        replace(ssn, '-');


-- sqlcl_snapshot {"hash":"0097f4361275cbf59f0b474acf3a3ccffffd2cdd","type":"VIEW","name":"EE_PORTFOLIO_SUMMARY_V","schemaName":"SAMQA","sxml":""}