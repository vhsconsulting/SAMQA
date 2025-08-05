-- liquibase formatted sql
-- changeset SAMQA:1754374142864 stripComments:false logicalFilePath:BASE_RELEASE\samqa\procedures\check_grace_period_claim.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/procedures/check_grace_period_claim.sql:null:eaca7f9484b0f3f7f960326cc86aa0a06f973dfc:create

create or replace procedure samqa.check_grace_period_claim (
    p_claim_id in number
) is

    type claim_detail_record is record (
            detail_id        number,
            service_date     date,
            service_end_date date,
            service_price    number,
            plan_type        varchar2(30),
            pers_id          number,
            line_status      varchar2(30),
            amount_approved  number,
            claim_amount     number
    );
    type claim_det_tbl is
        table of claim_detail_record index by binary_integer;
    l_claim_det             claim_det_tbl;
    a_claim_det             claim_det_tbl;
    l_past_year_amount      number := 0;
    l_current_year_amount   number := 0;
    l_grace_period_amount   number := 0;
    l_split_amount          number := 0;
    l_claim_amount          number := 0;
    l_acc_id                number;
    l_pers_id               number;
    l_account_type          varchar2(30);
    l_plan_type             varchar2(30);
    l_claim_id              number;
    l_split_claim_count     number := 0;
    l_rule_id               number;
    l_deductible_amount     number;
    l_approved_amount       number := 0;
    l_previous_year_balance number := 0;
begin
    select
        a.claim_detail_id,
        a.service_date,
        nvl(a.service_end_date, a.service_date) service_end_date,
        a.service_price,
        b.service_type,
        b.pers_id,
        nvl(a.line_status, 'PENDING'),
        0,
        b.claim_amount
    bulk collect
    into l_claim_det
    from
        claim_detail a,
        claimn       b
    where
            a.claim_id = p_claim_id
        and a.claim_id = b.claim_id
    order by
        a.service_date asc;

    a_claim_det := l_claim_det;
    if l_claim_det.count > 0 then
        for i in 1..l_claim_det.count loop
            for x in (
                select
                    pc_account.acc_balance(c.acc_id,
                                           d.plan_start_date,
                                           d.plan_end_date,
                                           c.account_type,
                                           l_claim_det(i).plan_type) - nvl(
                        pc_claim.get_pending_claim_amount(p_claim_id, c.pers_id, d.plan_type, d.plan_start_date, d.plan_end_date),
                        0
                    )                    acc_bal,
                    plan_start_date,
                    plan_end_date,
                    nvl(grace_period, 0) grace_period,
                    d.plan_type,
                    c.account_type,
                    c.acc_id,
                    c.pers_id,
                    d.annual_election,
                    d.ben_plan_id
                from
                    ben_plan_enrollment_setup d,
                    account                   c
                where
                        d.acc_id = c.acc_id
                    and c.pers_id = l_claim_det(i).pers_id
                    and d.plan_type = l_claim_det(i).plan_type
                    and l_claim_det(i).service_date >= trunc(d.plan_start_date)
                    and plan_end_date < sysdate
                order by
                    d.plan_start_date asc
            ) loop
                l_acc_id := x.acc_id;
                l_pers_id := x.pers_id;
                l_account_type := x.account_type;
                l_plan_type := x.plan_type;
                l_previous_year_balance := x.acc_bal;
                l_claim_amount := a_claim_det(i).claim_amount;
                if
                    l_claim_det(i).service_date >= x.plan_start_date
                    and l_claim_det(i).service_end_date <= x.plan_end_date
                    and x.plan_end_date < trunc(sysdate)
                then
       --     l_past_year_amount := LEAST(l_past_year_amount+ l_claim_det(i).service_price,x.acc_bal);
                    l_past_year_amount := l_past_year_amount + l_claim_det(i).service_price;
                    a_claim_det(i).line_status := 'PREVIOUS_YEAR';
                end if;

                pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM',
                                 'l_claim_det(i).service_date  ' || l_claim_det(i).service_date);
                pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM',
                                 'l_claim_det(i).service_end_date ' || l_claim_det(i).service_end_date);
                pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'x.plan_start_date ' || x.plan_start_date);
                pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'x.plan_end_date ' || x.plan_end_date);
                pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM',
                                 'x.plan_end_date+ x.grace_period  '
                                 || to_char(x.plan_end_date + x.grace_period));

                if
                            l_claim_det(i).service_date >= x.plan_start_date
                        and l_claim_det(i).service_end_date > x.plan_end_date
                        and l_claim_det(i).service_end_date <= x.plan_end_date + x.grace_period
                                                                                 and x.plan_end_date < trunc(sysdate)
                    and x.plan_end_date + x.grace_period >= trunc(sysdate)
                    and x.acc_bal > 0
                then
         --   l_grace_period_amount := LEAST(l_grace_period_amount + l_claim_det(i).service_price,x.acc_bal);
                    l_grace_period_amount := l_grace_period_amount + l_claim_det(i).service_price;
                    a_claim_det(i).line_status := 'GRACE_PERIOD';
                end if;

                for xx in (
                    select
                        deductible_rule_id
                    from
                        ben_plan_coverages a
                    where
                        a.ben_plan_id = x.ben_plan_id
                ) loop
                    l_rule_id := xx.deductible_rule_id;
                end loop;

                if l_rule_id is not null then
                    pc_claim.get_deductible(
                        p_acc_id          => x.acc_id,
                        p_plan_start_date => x.plan_start_date,
                        p_plan_end_date   => x.plan_end_date,
                        p_plan_type       => x.plan_type,
                        p_pers_id         => x.pers_id,
                        p_pers_patient    => x.pers_id,
                        p_rule_id         => l_rule_id,
                        p_annual_election => x.annual_election,
                        p_claim_amount    => l_claim_amount,
                        x_deductible      => l_deductible_amount,
                        x_payout_amount   => l_approved_amount
                    );
                end if;

            end loop;
        end loop;

        for i in 1..l_claim_det.count loop
            for x in (
                select
                    plan_start_date,
                    plan_end_date,
                    nvl(grace_period, 0) grace_period,
                    d.plan_type,
                    c.account_type,
                    c.acc_id,
                    c.pers_id
                from
                    ben_plan_enrollment_setup d,
                    account                   c
                where
                        d.acc_id = c.acc_id
                    and c.pers_id = l_claim_det(i).pers_id
                    and d.plan_type = l_claim_det(i).plan_type
                    and l_claim_det(i).service_date >= trunc(d.plan_start_date)
                    and plan_end_date >= trunc(sysdate)
                order by
                    d.plan_start_date asc
            ) loop
                if
                    l_claim_det(i).service_date >= x.plan_start_date
                    and l_claim_det(i).service_end_date <= x.plan_end_date
                    and x.plan_end_date >= trunc(sysdate)
                then
                    if l_past_year_amount + l_grace_period_amount = 0 then
                        l_current_year_amount := l_current_year_amount + l_claim_det(i).service_price;
                        a_claim_det(i).line_status := 'CURRENT_YEAR';
                    else
                        l_split_amount := l_claim_amount;
            -- Deduct any past year balance
                        l_split_amount := l_split_amount - ( l_past_year_amount - nvl(l_deductible_amount, 0) );

            -- if the grace period amount and past year amount
            -- is greater than available balance then just deduct grace period amount
                        if l_past_year_amount + l_grace_period_amount < l_previous_year_balance then
                            l_split_amount := l_split_amount - l_grace_period_amount;
                        end if;
            -- if the past year amount is less than available balance
            -- but grace and past year is greater than previous year available balance
            -- then deduct that amount
                        if
                            l_past_year_amount < l_previous_year_balance
                            and l_past_year_amount + l_grace_period_amount > l_previous_year_balance
                        then
                            l_split_amount := l_split_amount - least(l_grace_period_amount,(l_previous_year_balance - l_past_year_amount
                            ));
                        end if;

                        if l_split_amount > 0 then
                            a_claim_det(i).line_status := 'SPLIT';
                        end if;
                    end if;

                end if;
            end loop;
        end loop;

    end if;

    pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'l_grace_period_amount ' || l_grace_period_amount);
    pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'l_past_year_amount ' || l_past_year_amount);
    pc_log.log_error('CHECK_GRACE_PERIOD_CLAIM', 'split amount ' || l_split_amount);
    for i in 1..a_claim_det.count loop
        update claim_detail
        set
            line_status = a_claim_det(i).line_status
        where
                claim_detail_id = a_claim_det(i).detail_id
            and claim_id = p_claim_id;

    end loop;

    if l_grace_period_amount + l_past_year_amount > 0 then
        for x in (
            select
                ben_plan_id,
                annual_election,
                plan_start_date,
                plan_end_date,
                pc_account.acc_balance(acc_id, plan_start_date, plan_end_date, l_account_type, l_plan_type) - nvl(
                    pc_claim.get_pending_claim_amount(p_claim_id, l_pers_id, l_plan_type, plan_start_date, plan_end_date),
                    0
                ) acc_bal
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id in (
                    select
                        max(ben_plan_id)
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = l_acc_id
                        and plan_type = l_plan_type
                        and plan_end_date < trunc(sysdate)
                )
        ) loop
            update claimn
            set
                plan_start_date =
                    case
                        when x.acc_bal > 0 then
                            x.plan_start_date
                        else
                            plan_start_date
                    end,
                plan_end_date =
                    case
                        when x.acc_bal > 0 then
                            x.plan_end_date
                        else
                            plan_end_date
                    end,
                claim_pending = least(x.acc_bal, l_grace_period_amount + l_past_year_amount),
                denied_amount = claim_amount - ( nvl(l_deductible_amount, 0) + least(x.acc_bal, l_grace_period_amount + l_past_year_amount
                ) ),
                deductible_amount = nvl(l_deductible_amount, 0),
                approved_amount = least(x.acc_bal, l_grace_period_amount + l_past_year_amount),
                note = note
                       || ':'
                       ||
                       case
                           when nvl(l_grace_period_amount, 0) > 0
                                and nvl(l_past_year_amount, 0) = 0
                                and nvl(l_split_amount, 0) = 0 then
                               ' Grace Period Claim for previous plan year ,grace period amount: ' || nvl(l_grace_period_amount, 0)
                           when nvl(l_grace_period_amount, 0) > 0
                                and l_past_year_amount = 0
                                and nvl(l_split_amount, 0) = 0 then
                               'Claim has service dates in grace period,past year amount:  ' || l_past_year_amount
                           when nvl(l_grace_period_amount, 0) > 0
                                and l_past_year_amount > 0
                                and nvl(l_split_amount, 0) = 0 then
                               'Claim has service dates in grace period and previous plan year,previous year service amount '
                               || l_past_year_amount
                               || ': grace period service amount '
                               || nvl(l_grace_period_amount, 0)
                           when nvl(l_grace_period_amount, 0) > 0
                                and nvl(l_split_amount, 0) > 0 then
                               'Claim has service dates in grace period and current plan year,previous year service amount '
                               || l_past_year_amount
                               || ': grace period service amount '
                               || nvl(l_grace_period_amount, 0)
                               || ' :split amount '
                               || l_split_amount
                           else
                               'CALCUALTED mamounts ,previous year service amount '
                               || l_past_year_amount
                               || ': grace period service amount '
                               || nvl(l_grace_period_amount, 0)
                               || ' :split amount '
                               || l_split_amount
                       end
            where
                claim_id = p_claim_id;

        end loop;

        if l_split_amount - nvl(l_deductible_amount, 0) > 0 then
            select
                count(*)
            into l_split_claim_count
            from
                claimn
            where
                source_claim_id = p_claim_id;

            for x in (
                select
                    plan_start_date plan_start_date,
                    plan_end_date   plan_end_date,
                    ben_plan_id,
                    annual_election
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = l_acc_id
                    and plan_type = l_plan_type
                    and plan_end_date > trunc(sysdate)
            ) loop
                for xx in (
                    select
                        min(service_date)     service_date,
                        max(service_end_date) service_end_date
                    from
                        claim_detail
                    where
                        line_status not in ( 'GRACE_PERIOD', 'PREVIOUS_YEAR' )
                        and claim_id = p_claim_id
                ) loop
                    if l_split_claim_count = 0 then
                        pc_claim.create_split_claim(p_claim_id, l_split_amount, x.plan_start_date, x.plan_end_date, xx.service_date,
                                                    xx.service_end_date, 0, l_claim_id);

                        update claimn
                        set
                            note = note
                                   || ':'
                                   || ' Claim has been split into '
                                   || l_claim_id
                        where
                            claim_id = p_claim_id;

                    else
                        update claimn
                        set
                            plan_start_date = x.plan_start_date,
                            plan_end_date = x.plan_end_date,
                            claim_pending = l_split_amount,
                            claim_amount = l_split_amount
                        where
                            source_claim_id = p_claim_id;

                    end if;
                end loop;
            end loop;

        end if;

    end if;

    for x in (
        select
            sum(
                case
                    when line_status = 'CURRENT_YEAR' then
                        1
                    else
                        0
                end
            ) current_yr_count,
            sum(
                case
                    when line_status <> 'CURRENT_YEAR' then
                        1
                    else
                        0
                end
            ) prev_yr_count
        from
            claim_detail
        where
            claim_id = p_claim_id
    ) loop
        if x.prev_yr_count = 0 then
            for xx in (
                select
                    plan_start_date plan_start_date,
                    plan_end_date   plan_end_date,
                    ben_plan_id,
                    annual_election
                from
                    ben_plan_enrollment_setup
                where
                        acc_id = l_acc_id
                    and plan_type = l_plan_type
                    and plan_end_date > trunc(sysdate)
            ) loop
                update claimn
                set
                    plan_start_date = xx.plan_start_date,
                    plan_end_date = xx.plan_end_date
                where
                    claim_id = p_claim_id;

            end loop;

        end if;
    end loop;

    for x in (
        select
            count(*) cnt
        from
            claim_detail
        where
                line_status = 'PENDING'
            and claim_id = p_claim_id
    ) loop
        if x.cnt > 0 then
            update claimn
            set
                note = note
                       || ':'
                       || ' Unable to determine plan years correctly based on service date range given'
            where
                claim_id = p_claim_id;

        end if;
    end loop;

end check_grace_period_claim;
/

