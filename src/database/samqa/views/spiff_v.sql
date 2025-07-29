create or replace force editionable view samqa.spiff_v (
    name,
    entrp_id,
    taxid,
    end_date,
    reg_date,
    salesrep_id,
    account_type,
    first_fund_date
) as
    select
        name,
        entrp_id,
        taxid,
        end_date,
        reg_date,
        salesrep_id,
        account_type,
        first_fund_date
    from
        (
            select
                a.name,
                a.entrp_id,
                b.acc_num,
                replace(
                    replace(a.entrp_code, '-'),
                    ' '
                ) taxid,
                b.end_date,
                b.reg_date,
                b.salesrep_id,
                b.account_type,
                (
                    select
                        min(check_date)
                    from
                        employer_deposits d
                    where
                        d.entrp_id = a.entrp_id
                ) first_fund_date
            from
                enterprise a,
                account    b
            where
                    a.entrp_id = b.entrp_id
                and b.end_date is null
                and exists (
                    select
                        count(*)
                    from
                        enterprise c,
                        account    d
                    where
                            replace(c.entrp_code, '-') = replace(a.entrp_code, '-')
                        and c.entrp_id = d.entrp_id
                    group by
                        replace(c.entrp_code, '-')
                    having
                        count(*) > 1
                )
        )
    where
        ( account_type <> 'HSA'
          and reg_date >= add_months(sysdate, -5) )
        or account_type = 'HSA'
        and ( first_fund_date >= add_months(sysdate, -5) );


-- sqlcl_snapshot {"hash":"237d9dfe650bee9e3a0dfb89990263565337c743","type":"VIEW","name":"SPIFF_V","schemaName":"SAMQA","sxml":""}