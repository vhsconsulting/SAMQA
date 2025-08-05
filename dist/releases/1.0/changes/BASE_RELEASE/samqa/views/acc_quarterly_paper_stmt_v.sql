-- liquibase formatted sql
-- changeset SAMQA:1754374166645 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\acc_quarterly_paper_stmt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/acc_quarterly_paper_stmt_v.sql:null:9a443a44aaab566ddfaaceedaa21deef57043ef9:create

create or replace force editionable view samqa.acc_quarterly_paper_stmt_v (
    rn,
    acc_id,
    acc_num,
    end_date,
    address,
    city,
    zip
) as
    select
        rownum rn,
        acc_id,
        p.acc_num,
        p.end_date,
        u.address,
        u.city,
        u.zip
    from
        person  u,
        account p
    where
            u.pers_id = p.pers_id
        and p.account_status in ( 1, 2 )
        and trunc(nvl(p.end_date, sysdate)) >= trunc(sysdate, 'YYYY')
        and ( address <> '00000' )
        and ( city <> '00000' )
        and ( zip <> '00000' )
        and p.account_type = 'HSA'
        and ( p.blocked_flag is null
              or p.blocked_flag = 'N' )--sk added on 04/09/2020 to exclude any possible fraud acc
        and not exists (
            select
                *
            from
                online_users
            where
                    tax_id = replace(u.ssn, '-')
                and user_status = 'A'
        )
    order by
        p.end_date asc;

