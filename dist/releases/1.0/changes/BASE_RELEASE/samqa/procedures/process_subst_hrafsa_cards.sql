-- liquibase formatted sql
-- changeset SAMQA:1754374145252 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\process_subst_hrafsa_cards.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/process_subst_hrafsa_cards.sql:null:082d529c8ad220894714fbb4df6ecda8d864ff95:create

create or replace procedure samqa.process_subst_hrafsa_cards is
begin

    -- If there are no claims to substantiate for the claims that are older than 46 days
    -- and if we have substantiated
    -- all the claims, then this process will unsuspend the cards
    for x in (
        select
            pers_id
        from
            (
                select distinct
                    (
                        select
                            count(*)
                        from
                            claimn c
                        where
                                unsubstantiated_flag = 'Y'
                            and c.pers_id = a.card_id
                            and ( trunc(sysdate - c.creation_date) >= 46 )
                    ) card_count,
                    acc_num,
                    pers_id
                from
                    card_debit                a,
                    account                   b,
                    ben_plan_enrollment_setup bp
                where
                        a.status = 4
                    and b.acc_id = bp.acc_id
                    and a.card_id = b.pers_id
                    and b.account_type in ( 'HRA', 'FSA' )
                    and bp.plan_end_date > sysdate
            )
        where
            card_count = 0
    ) loop
        update card_debit
        set
            status = 7 --Un-Suspend
            ,
            last_update_date = sysdate
        where
                card_id = x.pers_id
            and status = 4;

        update card_debit
        set
            status = 7 --Un-Suspend
            ,
            last_update_date = sysdate
        where
            card_id in (
                select
                    pers_id
                from
                    person
                where
                    pers_main = x.pers_id
            )
            and status = 4;

    end loop;
    -- If there are  claims to substantiate and even if there is one claim
    -- remaining, then this process will suspend the cards after 45 days

    for x in (
        select distinct
            acc_id,
            pers_id,
            acc_num
        from
            (
                select
                    a.claim_id,
                    a.claim_date,
                    a.creation_date,
                    b.acc_id,
                    a.pers_id,
                    b.acc_num,
                    trunc(sysdate - a.creation_date) no_of_days
                from
                    claimn     a,
                    account    b,
                    card_debit d
                where
                        unsubstantiated_flag = 'Y'
                    and a.pers_id = b.pers_id
                    and b.account_type in ( 'HRA', 'FSA' )
                    and a.creation_date is not null
                    and a.pers_id = d.card_id
                    and d.status <> 4
            )
        where
            no_of_days >= 46
    ) loop
        update card_debit
        set
            status = 7 --Un-Suspend
            ,
            last_update_date = sysdate
        where
                card_id = x.pers_id
            and status = 4;

        update card_debit
        set
            status = 7 --Un-Suspend
            ,
            last_update_date = sysdate
        where
            card_id in (
                select
                    pers_id
                from
                    person
                where
                    pers_main = x.pers_id
            )
            and status = 4;

    end loop;

end process_subst_hrafsa_cards;
/

