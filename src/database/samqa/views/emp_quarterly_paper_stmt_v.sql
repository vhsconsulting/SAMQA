create or replace force editionable view samqa.emp_quarterly_paper_stmt_v (
    rn,
    acc_id,
    acc_num,
    end_date
) as
    select
        rownum rn,
        acc_id,
        p.acc_num,
        p.end_date
    from
        enterprise u,
        account    p
    where
        not exists (
            select
                *
            from
                online_users
            where
                find_key = p.acc_num
        )
            and p.plan_code in ( 1, 2, 3 )
            and u.entrp_id = p.entrp_id
            and p.end_date is null
            and p.account_status = 1
            and p.account_type = 'HSA'
            and ( ( nvl(address, '0') <> '0' )
                  and ( nvl(city, '0') <> '0' ) )
    order by
        p.end_date asc;


-- sqlcl_snapshot {"hash":"27252879dab031b0666ac810aeff891a66e87ee2","type":"VIEW","name":"EMP_QUARTERLY_PAPER_STMT_V","schemaName":"SAMQA","sxml":""}