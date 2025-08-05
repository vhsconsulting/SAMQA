-- liquibase formatted sql
-- changeset SAMQA:1754374167744 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\active_cobra_qb_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/active_cobra_qb_v.sql:null:bfeef968d3e1d315bd7898ced1bf2e5846313614:create

create or replace force editionable view samqa.active_cobra_qb_v (
    employer_name,
    full_name,
    acc_num,
    memberid,
    ssn,
    email,
    address,
    city,
    state,
    zip
) as
    with cobra as (
        select
            a.acc_num,
            q.memberid,
            p.ssn,
            p.entrp_id,
            p.first_name
            || ' '
            || p.last_name     full_name,
            p.email,
            p.address,
            p.city,
            p.state,
            p.zip,
            sum(
                case
                    when pl.ldoc < sysdate then
                        1
                    else
                        0
                end
            )                  termed_plan,
            sum(
                case
                    when pl.ldoc >= sysdate then
                        1
                    else
                        0
                end
            )                  active_plan,
            count(pl.qbplanid) all_plan,
            max(pl.ldoc)       ldoc
        from
            person  p,
            qb      q,
            account a,
            qbplan  pl,
            account e
        where
                p.ssn = q.ssn
            and p.pers_id = a.pers_id
            and a.account_type = 'COBRA'
            and p.person_type = 'QB'
            and pl.memberid = q.memberid
            and p.entrp_id = e.entrp_id
            and e.account_status = 1
            and pl.status in ( 'P', 'E' )
        group by
            a.acc_num,
            q.memberid,
            p.ssn,
            p.entrp_id,
            p.first_name
            || ' '
            || p.last_name,
            p.email,
            p.address,
            p.city,
            p.state,
            p.zip
    )
    select
        pc_entrp.get_entrp_name(entrp_id) employer_name,
        full_name,
        acc_num,
        memberid,
        ssn,
        email,
        address,
        city,
        state,
        zip
    from
        cobra
    where
            termed_plan = 0
        and active_plan = all_plan
    union
    select
        pc_entrp.get_entrp_name(entrp_id) employer_name,
        full_name,
        acc_num,
        memberid,
        ssn,
        email,
        address,
        city,
        state,
        zip
    from
        cobra
    where
            termed_plan > 0
        and active_plan > 0;

