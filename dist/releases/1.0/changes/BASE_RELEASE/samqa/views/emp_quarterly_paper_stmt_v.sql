-- liquibase formatted sql
-- changeset SAMQA:1754374172204 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\emp_quarterly_paper_stmt_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/emp_quarterly_paper_stmt_v.sql:null:27252879dab031b0666ac810aeff891a66e87ee2:create

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

