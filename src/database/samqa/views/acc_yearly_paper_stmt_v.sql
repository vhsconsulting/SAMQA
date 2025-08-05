create or replace force editionable view samqa.acc_yearly_paper_stmt_v (
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
        person  u,
        account p
    where
            u.pers_id = p.pers_id
        and p.account_status in ( 1, 3, 4 )
        and p.start_date < trunc(sysdate, 'YYYY')
        and p.account_type = 'HSA'
        and ( p.end_date is null
              or trunc(end_date, 'YYYY') = trunc(trunc(sysdate, 'YYYY') - 1,
                                                 'YYYY') )
        and ( ( nvl(address, '0') <> '0' )
              and ( nvl(city, '0') <> '0' )
              and city not like '0000%'
              and zip not like '00000' )
        and ( exists (
            select
                *
            from
                income i
            where
                    i.acc_id = p.acc_id
                and fee_date >= trunc(trunc(sysdate, 'YYYY') - 1,
                                      'YYYY') - 1
        )
              or exists (
            select
                *
            from
                payment i
            where
                    i.acc_id = p.acc_id
                and pay_date >= trunc(trunc(sysdate, 'YYYY') - 1,
                                      'YYYY') - 1
        ) )
        and ( suspended_date is null
              or trunc(suspended_date, 'YYYY') = trunc(trunc(sysdate, 'YYYY') - 1,
                                                       'YYYY') )
        and not exists (
            select
                *
            from
                online_users
            where
                tax_id = replace(u.ssn, '-')
        );


-- sqlcl_snapshot {"hash":"55ec178842db2a0f90a606d4c27ed073f32ff724","type":"VIEW","name":"ACC_YEARLY_PAPER_STMT_V","schemaName":"SAMQA","sxml":""}