create or replace force editionable view samqa.er_portfolio_summary_v (
    entrp_code,
    hsa_find_key,
    hra_find_key,
    fsa_find_key,
    cob_find_key,
    hsa_acc_id,
    hra_acc_id,
    fsa_acc_id,
    cob_acc_id
) as
    select
        replace(entrp_code, '-') entrp_code,
        max(
            case
                when account_type = 'HSA' then
                    acc_num
                else
                    null
            end
        )                        hsa_find_key,
        max(
            case
                when account_type = 'HRA' then
                    acc_num
                else
                    null
            end
        )                        hra_find_key,
        max(
            case
                when account_type = 'FSA' then
                    acc_num
                else
                    null
            end
        )                        fsa_find_key,
        max(
            case
                when account_type = 'COBRA' then
                    acc_num
                else
                    null
            end
        )                        cobra_find_key,
        max(
            case
                when account_type = 'HSA' then
                    acc_id
                else
                    null
            end
        )                        hsa_acc_id,
        max(
            case
                when account_type = 'HRA' then
                    acc_id
                else
                    null
            end
        )                        hra_acc_id,
        max(
            case
                when account_type = 'FSA' then
                    acc_id
                else
                    null
            end
        )                        fsa_acc_id,
        max(
            case
                when account_type = 'COBRA' then
                    acc_id
                else
                    null
            end
        )                        cob_acc_id
    from
        account    a,
        enterprise b
    where
            a.entrp_id = b.entrp_id
        and ( a.end_date > sysdate
              or a.end_date is null )
    group by
        replace(entrp_code, '-');


-- sqlcl_snapshot {"hash":"13f0440a2e4f2ee326f037daa2728523256e4904","type":"VIEW","name":"ER_PORTFOLIO_SUMMARY_V","schemaName":"SAMQA","sxml":""}