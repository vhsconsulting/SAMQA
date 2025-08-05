create or replace force editionable view samqa.emp_yearly_paper_stmt_v (
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
            and u.entrp_id = p.entrp_id
            and p.account_type = 'HSA'
            and trunc(p.start_date, 'YYYY') <= trunc(trunc(sysdate, 'YYYY') - 1,
                                                     'YYYY')
            and ( p.end_date is null
                  or trunc(p.end_date, 'YYYY') = trunc(trunc(sysdate, 'YYYY') - 1,
                                                       'YYYY') )
            and p.account_status = 1
            and ( ( nvl(address, '0') <> '0' )
                  and ( nvl(city, '0') <> '0' ) )
    order by
        p.end_date asc;


-- sqlcl_snapshot {"hash":"6fbf9eab5c3ab5f37ba7c66d29e15c41795dd4fc","type":"VIEW","name":"EMP_YEARLY_PAPER_STMT_V","schemaName":"SAMQA","sxml":""}