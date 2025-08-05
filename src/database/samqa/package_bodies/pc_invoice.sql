create or replace package body samqa.pc_invoice as

-- When invoices are posted, this procedures updates the amounts
-- for reconciliation
-- If it is not posted, and we have ACH in pending status then
-- it updates the amounts
    g_division_code varchar2(100);

    procedure apply_minimum_fee (
        p_invoice_id in number
    ) is
        l_invoice_line_id number;
        l_paid_by         varchar2(100);
    begin
        for x in (
            select
                invoice_id,
                invoice_date,
                entity_id,
                entity_type,
                billing_date,
                rate_plan_id,
                start_date,
                end_date,
                plan_type,
                invoice_amount,
                case
                    when plan_type = 'HRAFSA'
                         and fsa_line_amount = 0 then
                        0
                    when plan_type = 'HRAFSA'
                         and fsa_line_amount > 0 then
                        fsa_line_amount + generic_line_amount
                    when plan_type = 'FSA' then
                        fsa_line_amount + generic_line_amount
                    else
                        0
                end fsa_line_amount,
                case
                    when plan_type = 'HRAFSA'
                         and fsa_line_amount = 0 then
                        hra_line_amount + generic_line_amount
                    when plan_type = 'HRAFSA'
                         and fsa_line_amount > 0 then
                        hra_line_amount
                    when plan_type = 'HRA' then
                        hra_line_amount + generic_line_amount
                    else
                        0
                end hra_line_amount,
                min_inv_amount,
                min_hra_inv_amount,
                monthly_count,
                batch_number,
                status,
                fsa_min_count,
                hra_min_count
            from
                (
                    select
                        ar.invoice_id,
                        ar.invoice_date,
                        ar.entity_id,
                        ar.entity_type,
                        ar.billing_date,
                        nvl(ar.plan_type,
                            decode(
                            pc_benefit_plans.get_entrp_ben_account_type(ar.entity_id),
                            'HRA',
                            'HRA',
                            'Stacked',
                            'HRAFSA',
                            'FSA'
                        ))                           plan_type,
                        sum(
                            case
                                when pr.reason_code in(67, 68) then
                                    0
                                else
                                    arl.total_line_amount
                            end
                        )                            invoice_amount,
                        nvl(a.min_inv_amount, 0)     min_inv_amount,
                        nvl(a.min_inv_hra_amount, 0) min_hra_inv_amount,
                        ar.rate_plan_id,
                        ar.start_date,
                        ar.end_date,
                        ar.status,
                        sum(
                            case
                                when pr.reason_mapping = 2 then
                                    1
                                else
                                    0
                            end
                        )                            monthly_count,
                        ar.batch_number,
                        sum(
                            case
                                when pr.reason_code = 67 then
                                    1
                                else
                                    0
                            end
                        )                            fsa_min_count,
                        sum(
                            case
                                when pr.reason_code = 68 then
                                    1
                                else
                                    0
                            end
                        )                            hra_min_count,
                        sum(
                            case
                                when pr.product_type = 'FSA'
                                     and reason_code <> 68 then
                                    arl.total_line_amount
                                else
                                    0
                            end
                        )                            fsa_line_amount,
                        sum(
                            case
                                when pr.product_type = 'HRA'
                                     and reason_code <> 67 then
                                    arl.total_line_amount
                                else
                                    0
                            end
                        )                            hra_line_amount,
                        sum(
                            case
                                when pr.product_type is null then
                                    arl.total_line_amount
                                else
                                    0
                            end
                        )                            generic_line_amount
                    from
                        ar_invoice         ar,
                        ar_invoice_lines   arl,
                        invoice_parameters a,
                        pay_reason         pr
                    where
                            ar.invoice_id = p_invoice_id
                        and ar.invoice_id = arl.invoice_id
                        and a.entity_id = ar.entity_id
                        and a.invoice_type = ar.invoice_reason
                        and arl.rate_code = to_char(pr.reason_code)
                        and ar.rate_plan_id = a.rate_plan_id
                        and ar.status in ( 'GENERATED', 'DRAFT' )
                        and arl.status in ( 'GENERATED', 'DRAFT' )
                        and a.status = 'A'
                        and pr.reason_code not in ( 50, 51 )
                    group by
                        ar.invoice_id,
                        ar.invoice_date,
                        ar.entity_id,
                        ar.entity_type,
                        ar.billing_date,
                        a.min_inv_amount,
                        a.min_inv_hra_amount,
                        ar.rate_plan_id,
                        ar.start_date,
                        ar.end_date,
                        ar.batch_number,
                        ar.status,
                        ar.plan_type,
                        ar.rate_plan_id
                    order by
                        1
                )
            where
                    monthly_count > 0
                and ( min_hra_inv_amount > 0
                      or min_inv_amount > 0 )
        ) loop

               -- dbms_output.put_line('in apply minimum fee X.plan_type' ||X.plan_type);
            if
                x.plan_type in ( 'HRAFSA', 'HRA' )
                and x.min_hra_inv_amount <> x.hra_line_amount
            then
                if
                    x.hra_min_count = 0
                    and x.min_hra_inv_amount > x.hra_line_amount
                then
                    pc_invoice.insert_invoice_line(
                        p_invoice_id        => x.invoice_id,
                        p_invoice_line_type => 'MINIMUM_FEE',
                        p_rate_code         => '68',
                        p_description       => 'HRA Minimum Fee',
                        p_quantity          => 1,
                        p_no_of_months      => 1,
                        p_rate_cost         => x.min_hra_inv_amount - x.hra_line_amount,
                        p_total_cost        => x.min_hra_inv_amount - x.hra_line_amount,
                        p_batch_number      => x.batch_number,
                        x_invoice_line_id   => l_invoice_line_id
                    );

                    update ar_invoice_lines
                    set
                        status = x.status
                    where
                        invoice_line_id = l_invoice_line_id;

                elsif x.hra_min_count > 0 then
                    update ar_invoice_lines
                    set
                        unit_rate_cost =
                            case
                                when x.min_hra_inv_amount > x.hra_line_amount then
                                    x.min_hra_inv_amount - x.hra_line_amount
                                when x.min_hra_inv_amount < x.hra_line_amount
                                     and x.hra_line_amount - x.min_hra_inv_amount > 0 then
                                    x.hra_line_amount - x.min_hra_inv_amount
                                else
                                    0
                            end,
                        total_line_amount =
                            case
                                when x.min_hra_inv_amount > x.hra_line_amount then
                                    x.min_hra_inv_amount - x.hra_line_amount
                                when x.min_hra_inv_amount < x.hra_line_amount
                                     and x.hra_line_amount - x.min_hra_inv_amount > 0 then
                                    x.hra_line_amount - x.min_hra_inv_amount
                                else
                                    0
                            end
                    where
                            invoice_id = x.invoice_id
                        and rate_code = '68';

                end if;
            end if;

            if
                x.plan_type in ( 'HRAFSA', 'FSA' )
                and x.min_inv_amount <> x.fsa_line_amount
                and x.min_inv_amount > 0
            then
                if
                    x.fsa_min_count = 0
                    and x.min_inv_amount > x.fsa_line_amount
                then
                    pc_invoice.insert_invoice_line(
                        p_invoice_id        => x.invoice_id,
                        p_invoice_line_type => 'MINIMUM_FEE',
                        p_rate_code         => '67',
                        p_description       => 'FSA Minimum Fee',
                        p_quantity          => 1,
                        p_no_of_months      => 1,
                        p_rate_cost         => x.min_inv_amount - x.fsa_line_amount,
                        p_total_cost        => x.min_inv_amount - x.fsa_line_amount,
                        p_batch_number      => x.batch_number,
                        x_invoice_line_id   => l_invoice_line_id
                    );

                    update ar_invoice_lines
                    set
                        status = x.status
                    where
                        invoice_line_id = l_invoice_line_id;

                elsif x.hra_min_count > 0 then
                    update ar_invoice_lines
                    set
                        unit_rate_cost =
                            case
                                when x.min_inv_amount > x.fsa_line_amount then
                                    x.min_inv_amount - x.fsa_line_amount
                                when x.min_inv_amount < x.fsa_line_amount
                                     and x.fsa_line_amount - x.min_inv_amount > 0 then
                                    x.fsa_line_amount - x.min_inv_amount
                                else
                                    0
                            end,
                        total_line_amount =
                            case
                                when x.min_inv_amount > x.fsa_line_amount then
                                    x.min_inv_amount - x.fsa_line_amount
                                when x.min_inv_amount < x.fsa_line_amount
                                     and x.fsa_line_amount - x.min_inv_amount > 0 then
                                    x.fsa_line_amount - x.min_inv_amount
                                else
                                    0
                            end
                    where
                            invoice_id = x.invoice_id
                        and rate_code = '67';

                end if;

            end if;

        end loop;
    end apply_minimum_fee;

    procedure update_invoice_amount (
        p_invoice_id in number,
        p_user_id    in number
    ) is
        l_count         number := 0;
        l_batch_number  number;
        l_invoice_limit number := 0;
    begin
        for x in (
            select
                invoice_id,
                invoice_amount,
                sum(nvl(check_amount, 0)) check_amount
            from
                (
                    select
                        a.invoice_id,
                        a.invoice_amount,
                        sum(b.check_amount) check_amount
                    from
                        ar_invoice        a,
                        employer_payments b
                    where
                        a.status in ( 'POSTED', 'PARTIALLY_POSTED' )
                        and a.invoice_id = b.invoice_id
                        and a.invoice_id = p_invoice_id
                        and b.reason_code not in ( 23, 25 )
                    group by
                        a.invoice_id,
                        a.invoice_amount
                    union all
                    select
                        a.invoice_id,
                        a.invoice_amount,
                        sum(b.check_amount) check_amount
                    from
                        ar_invoice        a,
                        employer_deposits b
                    where
                        a.status in ( 'POSTED', 'PARTIALLY_POSTED' )
                        and a.invoice_id = b.invoice_id
                        and a.invoice_id = p_invoice_id
                    group by
                        a.invoice_id,
                        a.invoice_amount
                )
            group by
                invoice_id,
                invoice_amount
        ) loop
            update ar_invoice
            set
                paid_amount = nvl(x.check_amount, 0)
            where
                invoice_id = x.invoice_id;

        end loop;

        for x in (
            select
                invoice_id,
                sum(line_amount) line_amount
            from
                (
                    select
                        a.invoice_id,
                        sum(b.total_line_amount) line_amount
                    from
                        ar_invoice       a,
                        ar_invoice_lines b
                    where
                            b.status = 'VOID'
                        and a.invoice_id = b.invoice_id
                        and a.invoice_id = p_invoice_id
                    group by
                        a.invoice_id
                    union
                    select
                        a.invoice_id,
                        sum(b.void_amount) line_amount
                    from
                        ar_invoice       a,
                        ar_invoice_lines b
                    where
                            b.status <> 'VOID'
                        and a.invoice_id = b.invoice_id
                        and a.invoice_id = p_invoice_id
                    group by
                        a.invoice_id
                )
            group by
                invoice_id
        ) loop
            update ar_invoice
            set
                void_amount = nvl(x.line_amount, 0)
            where
                    invoice_id = x.invoice_id
                and nvl(void_amount, 0) = 0;

        end loop;

        for x in (
            select
                batch_number
            from
                ar_invoice
            where
                    invoice_id = p_invoice_id
                and invoice_reason = 'FEE'
                and status in ( 'GENERATED', 'DRAFT' )
        ) -- Added by Joshi for production fix
         loop
            l_batch_number := x.batch_number;
            apply_tax(l_batch_number);
            apply_service_charge(x.batch_number);
            apply_minimum_fee(p_invoice_id);
        end loop;

        for x in (
            select
                invoice_id,
                invoice_date,
                entity_id,
                entity_type,
                billing_date,
                void_amount,
                invoice_reason,
                refund_amount
         --           , DECODE(PC_BENEFIT_PLANS.get_entrp_ben_account_type(entity_id),'HRA','HRA','Stacked','HRAFSA','FSA') PLAN
                ,
                sum(invoice_amount1) invoice_amount1	 -- 5323
                ,
                sum(invoice_amount)  invoice_amount
            from
                (
                    select
                        ar.invoice_id,
                        ar.invoice_date,
                        ar.entity_id,
                        ar.entity_type,
                        ar.billing_date,
                        decode(pr.plan_type, 'HRA', 'HRA', 'FSA')                                                plan_type
                          -- ,sum(ARL.TOTAL_LINE_AMOUNT+ NVL(ARL.VOID_AMOUNT,0)) INVOICE_AMOUNT1 -- ticket 5323
                          -- , sum(ARL.TOTAL_LINE_AMOUNT) INVOICE_AMOUNT
                        ,
                        sum(decode(arl.status, 'CANCELLED', 0, arl.total_line_amount) + nvl(arl.void_amount, 0)) invoice_amount1 -- ticket 5323   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                        ,
                        sum(decode(arl.status, 'CANCELLED', 0, arl.total_line_amount))                           invoice_amount     -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                        ,
                        nvl(a.min_inv_amount, 0)                                                                 min_inv_amount,
                        nvl(a.min_inv_hra_amount, 0)                                                             min_hra_inv_amount,
                        ar.void_amount,
                        ar.invoice_reason,
                        ar.refund_amount,
                        ar.batch_number,
                        sum(
                            case
                                when pr.reason_mapping in(1, 30) then
                                    1
                                else
                                    0
                            end
                        )                                                                                        setup_renew_count
                    from
                        ar_invoice         ar,
                        ar_invoice_lines   arl,
                        invoice_parameters a,
                        pay_reason         pr
                    where
                            ar.invoice_id = p_invoice_id
                        and ar.invoice_id = arl.invoice_id
                        and a.status = 'A'
                        and a.rate_plan_id = ar.rate_plan_id
                        and arl.status <> 'VOID' -- 5323
                        and ar.status not in ( 'POSTED', 'VOID', 'RETURNED' ) --,'CANCELLED')   -- Commented Cancelled by Swamy for Ticket#9860 on 26/04/2021
                        and a.entity_id = ar.entity_id
                        and a.invoice_type = ar.invoice_reason
                        and arl.rate_code = to_char(pr.reason_code)
                    group by
                        ar.invoice_id,
                        ar.invoice_date,
                        ar.entity_id,
                        ar.entity_type,
                        ar.billing_date,
                        a.min_inv_amount,
                        a.min_inv_hra_amount,
                        decode(pr.plan_type, 'HRA', 'HRA', 'FSA'),
                        ar.void_amount,
                        ar.invoice_reason,
                        ar.refund_amount,
                        ar.batch_number
                    order by
                        1
                )
            group by
                invoice_id,
                invoice_date,
                entity_id,
                entity_type,
                billing_date,
                void_amount,
                invoice_reason,
                refund_amount,
                batch_number
        ) loop


                        /* UPDATE AR_INVOICE
                         SET  --PENDING_AMOUNT =  (X.INVOICE_AMOUNT+nvl(X.REFUND_AMOUNT,0))-(nvl(PAID_AMOUNT,0)+NVL(x.VOID_AMOUNT,0))  commented for 5323
                              -- INVOICE_AMOUNT = X.INVOICE_AMOUNT commented for 5323
                               PENDING_AMOUNT =  (decode( STATUS,'GENERATED',x.INVOICE_AMOUNT,'DRAFT', x.INVOICE_AMOUNT,x.INVOICE_AMOUNT1) +nvl(X.REFUND_AMOUNT,0))-(nvl(PAID_AMOUNT,0)+NVL(x.VOID_AMOUNT,0))
                           ,   INVOICE_AMOUNT =  decode( STATUS,'GENERATED',x.INVOICE_AMOUNT,'DRAFT', x.INVOICE_AMOUNT,x.INVOICE_AMOUNT1)
                           ,    LAST_UPDATE_DATE = SYSDATE
                           ,    LAST_UPDATED_BY = P_USER_ID
                         WHERE  INVOICE_ID = X.INVOICE_ID;
                          */
                          -- Commented above and added below by Swamy for Ticket#9889 on 13/05/2021
            update ar_invoice
            set
                pending_amount = ( decode(status, 'GENERATED', x.invoice_amount, 'CANCELLED', 0,
                                          'DRAFT', x.invoice_amount, x.invoice_amount1) + nvl(x.refund_amount, 0) ) - ( nvl(paid_amount
                                          , 0) + nvl(x.void_amount, 0) ),
                invoice_amount = decode(status, 'GENERATED', x.invoice_amount, 'CANCELLED', invoice_amount,
                                        'DRAFT', x.invoice_amount, x.invoice_amount1),
                void_amount = decode(status, 'CANCELLED', invoice_amount, void_amount),
                last_update_date = sysdate,
                last_updated_by = p_user_id         -- addded by Jaggi #11618
            where
                invoice_id = x.invoice_id;

            select
                count(*)
            into l_count
            from
                ach_transfer
            where
                    invoice_id = x.invoice_id
                and status in ( 1, 2 );

            if l_count > 0 then
                update ach_transfer
                set
                    fee_amount =
                        case
                            when x.invoice_reason = 'FEE' then
                                nvl(x.invoice_amount, 0) - nvl(x.void_amount, 0)
                            else
                                0
                        end,
                    amount =
                        case
                            when x.invoice_reason <> 'FEE' then
                                nvl(x.invoice_amount, 0) - nvl(x.void_amount, 0)
                            else
                                0
                        end,
                    total_amount = nvl(x.invoice_amount, 0) - nvl(x.void_amount, 0),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        invoice_id = x.invoice_id
                    and status in ( 1, 2 );

            end if;

        end loop;

        update ar_invoice
        set
            pending_amount =
                case
                    when invoice_amount - nvl(void_amount, 0) = nvl(paid_amount, 0) then
                        0
                    when invoice_amount < nvl(paid_amount, 0)                       then
                        invoice_amount + nvl(refund_amount, 0) - ( ( nvl(void_amount, 0) + nvl(paid_amount, 0) ) )
                    else
                        invoice_amount - ( ( nvl(void_amount, 0) + nvl(paid_amount, 0) ) )
                end
        where
                invoice_id = p_invoice_id
            and status <> 'RETURNED';

        update ar_invoice
        set
            status =
                case
                    when paid_amount = invoice_amount + nvl(refund_amount, 0) - nvl(void_amount, 0) then
                        'POSTED'
                    when paid_amount = invoice_amount - nvl(void_amount, 0)                         then
                        'POSTED'
                    when paid_amount > 0
                         and paid_amount < invoice_amount - nvl(void_amount, 0) then
                        'PARTIALLY_POSTED'
                    when paid_amount = 0
                         and approved_date is not null
                         and status not in ( 'DRAFT', 'VOID', 'CANCELLED' ) then
                        'PROCESSED'
                    else
                        status
                end
        where
                invoice_id = p_invoice_id
            and status in ( 'PARTIALLY_POSTED', 'POSTED' );

           -- Added by Joshi for 10746.
        l_invoice_limit := pc_lookups.get_meaning('INVOICE_LIMIT', 'WIRE_TRANSFER_LIMIT');
        update ar_invoice
        set
            payment_method =
                case
                    when invoice_amount >= l_invoice_limit
                         and payment_method <> 'WIRE_TRANSFER' then
                        'WIRE_TRANSFER'
                    when invoice_amount < l_invoice_limit
                         and payment_method = 'WIRE_TRANSFER' then
                        'CHECK'
                    else
                        payment_method
                end,
            bank_acct_id =
                case
                    when invoice_amount >= l_invoice_limit then
                        null
                    else
                        bank_acct_id
                end
        where
                status = 'GENERATED'
            and invoice_id = p_invoice_id;
            -- code ends here 10746

    end update_invoice_amount;

-- Procedure , not used
    procedure update_inv_amounts (
        p_invoice_id in number,
        p_user_id    in number
    ) is
    begin
        pc_log.log_error('PC_INVOICE.UPDATE_INV_AMOUNTS', 'p_invoice_id' || p_invoice_id);
        for x in (
            select
                sum(check_amount)                posted_amount,
                b.invoice_amount - b.void_amount invoice_amount
                          --, A.PAYMENT_BATCH_ID
                ,
                b.batch_number
            from
                employer_payments a,
                ar_invoice        b
            where
                    b.invoice_id = p_invoice_id
                and a.invoice_id = b.invoice_id
                and b.status = 'POSTED'
            group by
                b.invoice_amount,
                b.void_amount,
                b.batch_number
                             --, A.PAYMENT_BATCH_ID
        ) loop
            if x.posted_amount >= x.invoice_amount then
                update ar_invoice
                set
                    status = 'POSTED',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    note = 'Posted on ' || to_char(sysdate, 'MM/DD/YYYY'),
                    invoice_posted_date = sysdate
                where
                        invoice_id = p_invoice_id
                    and status = 'PROCESSED';

                update ar_invoice_lines
                set
                    status = 'POSTED',
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    note = 'Posted on ' || to_char(sysdate, 'MM/DD/YYYY')
                where
                        invoice_id = p_invoice_id
                    and status = 'PROCESSED';

            else
                update ar_invoice
                set
                    paid_amount = x.posted_amount,
                    pending_amount = x.invoice_amount - x.posted_amount,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id,
                    note = 'Posted on ' || to_char(sysdate, 'MM/DD/YYYY')
                where
                        invoice_id = p_invoice_id
                    and status = 'PROCESSED';

            end if;
        end loop;

       -- POST_INV_REBATE_TO_EE(P_INVOICE_ID,P_USER_ID); --revise

    end update_inv_amounts;

-- Called from APEX screen, when invoices are approved
    procedure approve_invoice (
        p_invoice_id in number,
        p_user_id    in number
    ) is

        l_return_status varchar2(3200);
        l_error_message varchar2(3200);
        l_count         number := 0;
        l_plan_type     varchar2(255);
        ls_stop_payment varchar2(1) := 'N';
    begin
        for x in (
            select
                a.batch_number,
                a.auto_pay,
                a.bank_acct_id,
                a.payment_method,
                a.pending_amount,
                a.acc_id,
                a.invoice_id,
                a.plan_type,
                b.account_type,
                a.invoice_reason
                   --,  B.SALESREP_ID  /*Ticket#5423 */
                   --,  B.AM_ID
                ,
                pc_sales_team.get_sales_rep_id(entity_id, sysdate, 'PRIMARY')   salesrep_id /*7703 Joshi commented above 2 line*/,
                pc_sales_team.get_sales_rep_id(entity_id, sysdate, 'SECONDARY') am_id  /*7703 Joshi commented above 2 line*/
                   /* commented for ticket 11296
                   ,  CASE WHEN b.account_type in ('HRA','FSA') AND A.INVOICE_REASON = 'FEE' THEN
                         add_business_days(3,sysdate)
                      WHEN b.account_type in ('HRA','FSA') AND A.INVOICE_REASON = 'CLAIM' THEN
                         sysdate+1
                      ELSE add_business_days(1,sysdate) END approval_date
                      */
                    /* changed transaction date logic as per ticket 11296.Joshi */,
                case
                    when b.account_type in ( 'HSA', 'LSA' )
                         and a.invoice_reason = 'FEE' then  -- Added by Swamy for Ticket#11688 14/07/2023
                        add_business_days(1, sysdate)
                    when b.account_type not in ( 'HSA', 'LSA' )
                         and a.invoice_reason = 'FEE' then
                        add_business_days(3, sysdate)
                    when b.account_type in ( 'HRA', 'FSA' )
                         and a.invoice_reason = 'CLAIM' then
                        sysdate + 1
                      -- Added by Jaggi. for COBRA Premium. if invoice is paid after 5pm. set transacton_date to 2 days from current day.
                    when b.account_type in ( 'COBRA' )
                         and a.invoice_reason = 'PREMIUM'
                         and to_number(to_char(current_timestamp, 'hh24')) <= to_number(to_char(trunc(current_timestamp) + 17 / 24,
                                                                                                'hh24')) then
                        add_business_days(1, sysdate)
                    when b.account_type in ( 'COBRA' )
                         and a.invoice_reason = 'PREMIUM'
                         and to_number(to_char(current_timestamp, 'hh24')) > to_number(to_char(trunc(current_timestamp) + 17 / 24,
                                                                                               'hh24')) then
                        add_business_days(2, sysdate)
                    else
                        add_business_days(1, sysdate)
                end                                                             approval_date,
                b.ga_id
            from
                ar_invoice a,
                account    b
            where
                    a.invoice_id = p_invoice_id
                and a.acc_id = b.acc_id
                and a.status = 'GENERATED'
        ) loop
            pc_log.log_error('approve_invoice', 'P_INVOICE_ID' || p_invoice_id);
            if
                x.plan_type is null
                and x.account_type in ( 'HRA', 'FSA' )
                and x.invoice_reason = 'CLAIM'
            then
                for xx in (
                    select distinct
                        plans
                    from
                        invoice_distribution_summary
                    where
                        invoice_id = p_invoice_id
                ) loop
                    l_plan_type := pc_lookups.get_meaning(xx.plans, 'FSA_HRA_PRODUCT_MAP');
                end loop;

            end if;

            update ar_invoice_lines
            set
                status = 'PROCESSED',
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    invoice_id = p_invoice_id
                and status = 'GENERATED';

            update ar_invoice
            set
                status = 'PROCESSED',
                invoice_due_date =
                    case
                        when x.auto_pay = 'Y'
                             and x.bank_acct_id is not null
                             and x.payment_method = 'DIRECT_DEPOSIT' then
                            x.approval_date
                        else
                            invoice_due_date
                    end,
                plan_type = nvl(l_plan_type, plan_type),
                approved_date = sysdate,
                salesrep_id = x.salesrep_id,
                am_id = x.am_id    /*Ticket#5423 */,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    invoice_id = p_invoice_id
                and status = 'GENERATED';

            if
                x.account_type = 'COBRA'
                and x.invoice_reason = 'PREMIUM'
            then  --Invoice_Reason added by rprabu on 26/05/2022
                update ar_invoice
                set
                    status = 'IN_PROCESS'
                where
                    invoice_id = p_invoice_id;

                update ar_invoice_lines
                set
                    status = 'IN_PROCESS'
                where
                    invoice_id = p_invoice_id;

            end if;

            if
                x.auto_pay = 'Y'
                and x.bank_acct_id is not null
                and x.payment_method = 'DIRECT_DEPOSIT'
            then

               /*Ticket#7391 */
                if x.account_type in ( 'HSA', 'LSA' ) then    -- LSA Added by Swamy for Ticket#10104
                    pc_log.log_error('approve_invoice', 'calling APPLY_INVOICE_PAYMENT P_INVOICE_ID' || p_invoice_id);
                    apply_invoice_payment(
                        p_batch_number       => x.batch_number,
                        p_transaction_number => null,
                        p_transaction_date   => x.approval_date --NVL(X.INVOICE_DUE_DATE-1,SYSDATE+1)
                        ,
                        p_payment_amount     => x.pending_amount,
                        p_acc_id             => x.acc_id,
                        p_invoice_id         => x.invoice_id,
                        p_note               => 'Invoice payment request by auto pay request ',
                        p_bank_account       => x.bank_acct_id,
                        p_user_id            => p_user_id,
                        p_pay_method         => 'DIRECT_DEPOSIT',
                        p_plan_type          => x.account_type   -- Replaced HSA with X.ACCOUNT_TYPE by Swamy for Ticket#10104 --'HSA'  --Ticket#7391
                        ,
                        p_invoice_reason     => x.invoice_reason,
                        x_return_status      => l_return_status,
                        x_error_message      => l_error_message
                    );

                else

                -- added by Joshi for GA consolidate stmt (11061)
                    if
                        x.account_type in ( 'FSA', 'HRA', 'COBRA' )
                        and x.invoice_reason = 'FEE'
                        and get_invoice_frequency(x.invoice_id) = 'MONTHLY'
                        and pc_general_agent.is_ga_consolidate_stmt_enabled(x.ga_id) = 'Y'
                    then
                        ls_stop_payment := 'Y';
                    else
                        ls_stop_payment := 'N';
                    end if;

                    if ls_stop_payment = 'N' then
                        apply_invoice_payment(
                            p_batch_number       => x.batch_number,
                            p_transaction_number => null,
                            p_transaction_date   => x.approval_date --NVL(X.INVOICE_DUE_DATE-1,SYSDATE+1)
                            ,
                            p_payment_amount     => x.pending_amount,
                            p_acc_id             => x.acc_id,
                            p_invoice_id         => x.invoice_id,
                            p_note               => 'Invoice payment request by auto pay request ',
                            p_bank_account       => x.bank_acct_id,
                            p_user_id            => p_user_id,
                            p_pay_method         => 'DIRECT_DEPOSIT',
                            p_plan_type          => x.plan_type,
                            p_invoice_reason     => x.invoice_reason,
                            x_return_status      => l_return_status,
                            x_error_message      => l_error_message
                        );

                    end if;

                end if;

                if l_return_status <> 'S' then
                    raise_application_error('-20001', l_error_message);
                end if;
            end if;

        end loop;
    end approve_invoice;

-- Creates ACH transsfer record with Fee transaction type for fee invoice and Contribution transaction type for Claim and Funding invoice
    procedure apply_invoice_payment (
        p_batch_number       in number,
        p_transaction_number in varchar2,
        p_transaction_date   in date,
        p_payment_amount     in number,
        p_acc_id             in number,
        p_invoice_id         in number,
        p_note               in varchar2,
        p_bank_account       in number,
        p_user_id            in number,
        p_pay_method         in varchar2,
        p_plan_type          in varchar2,
        p_invoice_reason     in varchar2,
        x_return_status      out varchar2,
        x_error_message      out varchar2
    ) is

        l_payment_batch_id number;
        l_transaction_id   number;
        l_count            number := 0;
        l_transaction_type varchar2(1) := 'C';
    begin
        pc_log.log_error('APPLY_INVOICE_PAYMENT', 'Processing');
        x_return_status := 'S';
        if p_pay_method = 'DIRECT_DEPOSIT' then
     -- insert into jtest(msg) values('direct deposit 1');
     --  commit;
            select
                count(*)
            into l_count
            from
                ach_transfer
            where
                    invoice_id = p_invoice_id
                and status in ( 1, 2 );

            if l_count = 0 then
       /*Ticket#7391 */
                if p_plan_type in ( 'HSA', 'LSA' ) then    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021
                    l_transaction_type := 'C';   -- Added by Swamy for Ticket#11047 on 09/05/2022
                    if p_plan_type = 'LSA' then
                        l_transaction_type := 'C';
                        for k in (
                            select
                                count(*) cnt
                            from
                                ar_invoice_lines arl,
                                pay_reason       pr
                            where
                                    arl.rate_code = pr.reason_code
                                and pr.reason_mapping = 1
                                and arl.invoice_id = p_invoice_id
                        ) loop
                            if k.cnt > 0 then
                                l_transaction_type := 'F';
                            end if;
                        end loop;

                    end if;

                    pc_ach_transfer.ins_ach_transfer(
                        p_acc_id           => p_acc_id,
                        p_bank_acct_id     => p_bank_account,
                        p_transaction_type => l_transaction_type  --'C' replaced by l_transaction_type by swamy for Ticket#11047  /* For HSA Contribution . Ticket#7391 */
                        ,
                        p_amount           =>
                                  case
                                      when p_invoice_reason = 'FEE' then
                                          0
                                      else
                                          p_payment_amount
                                  end,
                        p_fee_amount       =>
                                      case
                                          when p_invoice_reason = 'FEE' then
                                              p_payment_amount
                                          else
                                              0
                                      end,
                        p_transaction_date => greatest(
                            nvl(p_transaction_date, sysdate),
                            sysdate
                        ),
                        p_reason_code      =>
                                       case
                                           when p_plan_type = 'LSA' then
                                               3
                                           else
                                               4
                                       end  -- Replaced 4 with CASE Swamy Ticket#10104
                                       ,
                        p_status           => 2 -- Pending
                        ,
                        p_user_id          => p_user_id,
                        p_pay_code         => 3,
                        x_transaction_id   => l_transaction_id,
                        x_return_status    => x_return_status,
                        x_error_message    => x_error_message
                    );

                    insert into ach_transfer_details (
                        xfer_detail_id,
                        transaction_id,
                        group_acc_id,
                        acc_id,
                        ee_amount,
                        er_amount,
                        ee_fee_amount,
                        er_fee_amount,
                        last_updated_by,
                        created_by,
                        last_update_date,
                        creation_date
                    )
                        select
                            ach_transfer_details_seq.nextval,
                            l_transaction_id,
                            p_acc_id,
                            (
                                select
                                    acc_id
                                from
                                    account
                                where
                                    pers_id = ids.pers_id
                            ),
                            0 --to_number(ee_amount)
                            ,
                            0 --to_number(er_amount)
                            ,
                            0 --to_number(ee_fee_amount)
                            ,
                            ids.rate_amount --to_number(er_fee_amount)
                            ,
                            p_user_id,
                            p_user_id,
                            sysdate,
                            sysdate
                        from
                            invoice_distribution_summary ids
                        where
                            invoice_id = p_invoice_id;

                else /* HSA LOOP */
                    pc_ach_transfer.ins_ach_transfer(
                        p_acc_id           => p_acc_id,
                        p_bank_acct_id     => p_bank_account,
                        p_transaction_type =>
                                            case
                                                when p_invoice_reason = 'FEE' then
                                                    'F'
                                                else
                                                    'C'
                                            end,
                        p_amount           =>
                                  case
                                      when p_invoice_reason = 'FEE' then
                                          0
                                      else
                                          p_payment_amount
                                  end,
                        p_fee_amount       =>
                                      case
                                          when p_invoice_reason = 'FEE' then
                                              p_payment_amount
                                          else
                                              0
                                      end,
                        p_transaction_date => greatest(
                            nvl(p_transaction_date, sysdate),
                            sysdate
                        ),
                        p_reason_code      =>
                                       case
                                           when p_invoice_reason = 'FEE' then
                                               2
                                           else
                                               4
                                       end,
                        p_status           => 2 -- Pending
                        ,
                        p_user_id          => p_user_id,
                        p_pay_code         => 3,
                        x_transaction_id   => l_transaction_id,
                        x_return_status    => x_return_status,
                        x_error_message    => x_error_message
                    );
                end if;/*End Ticket#7391 */

                if x_return_status = 'S' then
                    update ach_transfer
                    set
                        plan_type = p_plan_type,
                        invoice_id = p_invoice_id,
                        ach_source = 'IN_OFFICE'
                    where
                        transaction_id = l_transaction_id;

                end if;

            else
                update ach_transfer
                set
                    fee_amount =
                        case
                            when p_invoice_reason = 'FEE' then
                                nvl(p_payment_amount, 0)
                            else
                                0
                        end,
                    amount =
                        case
                            when p_invoice_reason = 'FEE' then
                                0
                            else
                                nvl(p_payment_amount, 0)
                        end,
                    total_amount = nvl(p_payment_amount, 0),
                    last_updated_by = p_user_id,
                    last_update_date = sysdate
                where
                        invoice_id = p_invoice_id
                    and status in ( 1, 2 );

            end if;

        end if;

  -- UPDATE_INV_AMOUNTS(P_INVOICE_ID,P_USER_ID);

    end apply_invoice_payment;

-- Called from APEX screen for generating fee invoices for all products

    procedure generate_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_account_type  in varchar2 default null,
        x_error_status  out varchar2,
        x_error_message out varchar2,
        p_invoice_type  in varchar2 default null,
        p_division_code in varchar2 default null,
        x_batch_number  out number
    ) is

        l_batch_number       number;
        l_exists             varchar2(1) := 'N';
        invoice_exception exception;
        l_return_status      varchar2(1);
        l_error_message      varchar2(32000);
        l_rate               number;
        l_quantity           number;
    --l_invoice_days    number;
   -- l_total           number;
        l_line_type          varchar2(50);
        l_fee_count          number := 0;
        l_renewal_count      number := 0;
        l_hra_renew_count    number := 0;
        l_fsa_renew_count    number := 0;
        l_inv_count          number := 0;
        l_invoice_id         number;
        l_invoice_line_id    number;
        l_total_inv_amount   number := 0;
        l_pers_tbl           number_table;
        l_pers_id            number;
        l_a_pers_tbl         number_table;
        l_a_quantity         number := 0;
        l_a_line_type        varchar2(30) := null;
        l_a_total_inv_amount number := 0;
        l_a_no_of_months     number := 0;
        l_at_pers_tbl        number_table;
        l_t_quantity         number := 0;
        l_t_line_type        varchar2(30) := null;
        l_t_total_inv_amount number := 0;
        l_t_no_of_months     number := 0;
--    l_account_type    VARCHAR2(30);

        i                    number := 0;
        l_no_of_months       number := 0;
        l_account_type       varchar2(30);
        l_takeover_flag      varchar2(10) := null;
        l_html               varchar2(2000);
        l_sql                varchar2(32000);
        l_invoice_limit      number := 0;
        l_user_id            number;
    begin
        pc_log.log_error('pc_invoice', 'started here');
        l_user_id := get_user_id(v('APP_USER'));
        pc_log.log_error('pc_invoice', 'user name ' || l_user_id);
        pc_log.log_error('PC_INVOICE.generate_invoice', 'P_ENTRP_ID ' || p_entrp_id);
        pc_log.log_error('pc_invoice', 'P_INVOICE_TYPE ' || p_invoice_type);
        pc_log.log_error('pc_invoice', 'P_START_DATE ' || p_start_date);
        pc_log.log_error('pc_invoice', 'P_END_DATE  ' || p_end_date);
        pc_log.log_error('pc_invoice', 'P_BILLING_DATE ' || p_billing_date);
        pc_log.log_error('pc_invoice', 'P_ENTRP_ID ' || p_entrp_id);
        pc_log.log_error('pc_invoice', 'P_ACCOUNT_TYPE ' || p_account_type);
        pc_log.log_error('pc_invoice', 'P_INVOICE_TYPE ' || p_invoice_type);
        pc_log.log_error('pc_invoice', 'P_DIVISION_CODE ' || p_division_code);
        pc_log.log_error('pc_invoice',
                         'user name ' || get_user_id(v('APP_USER')));
        if p_entrp_id is not null then
            select
                account_type
            into l_account_type
            from
                account
            where
                entrp_id = p_entrp_id;

        end if;

        select
            invoice_batch_seq.nextval
        into l_batch_number
        from
            dual;

        if p_account_type is not null then
            l_account_type := p_account_type;
        end if;
        pc_log.log_error('PC_INVOICE.generate_invoice', 'l_account_type ' || l_account_type);
        pc_log.log_error('PC_INVOICE.generate_invoice', 'P_DIVISION_CODE ' || p_division_code);

    -- Monthly  time invoice
        insert into ar_invoice (
            invoice_id,
            invoice_number,
            invoice_date,
            billing_date,
            invoice_due_date,
            invoice_type,
            invoice_amount,
            pending_amount,
            acc_id,
            acc_num,
            entity_id,
            entity_type,
            invoice_term,
            auto_pay,
            rate_plan_id,
            payment_method,
            batch_number,
            status,
            last_invoiced_date,
            start_date,
            end_date,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            bank_acct_id,
            billing_name,
            billing_attn,
            billing_address,
            billing_city,
            billing_zip,
            billing_state
        )
            select
                ar_invoice_seq.nextval,
                invoice_number_seq.nextval,
                case
                    when l_account_type = 'HSA' then
                        p_end_date  /*Ticket#7391 */
                    when l_account_type = 'LSA' then
                        p_end_date   -- Added by Swamy for Ticket#9912 on 10/08/2021
                    else
                        nvl(p_billing_date,
                            to_date('10-'
                                    || to_char(sysdate, 'MON-YYYY'),
                            'DD-MON-YYYY'))
                end                                        invoice_date,
                nvl(p_billing_date,
                    to_date('10-'
                            || to_char(sysdate, 'MON-YYYY'),
                    'DD-MON-YYYY'))                        billing_date,
                decode(p_billing_date,
                       null,
                       to_date('10-'
                               || to_char(sysdate, 'MON-YYYY'),
                       'DD-MON-YYYY'),
                       sysdate) + decode(a.payment_term,
                                         'NET7',
                                         7,
                                         'NET60',
                                         60,
                                         'NET30',
                                         30,
                                         'NET15',
                                         15,
                                         'NET90',
                                         90,
                                         'PIA',
                                         1,
                                         'IMMEDIATE',
                                         5,
                                         round(add_bus_days(sysdate, 4) - sysdate)) invoice_due_date,
                'AUTO',
                0,
                0,
                b.acc_id,
                b.acc_num,
                b.entrp_id,
                'EMPLOYER',
                a.payment_term,
                a.autopay,
                c.rate_plan_id,
                a.payment_method,
                l_batch_number,
                'DRAFT',
                a.last_invoiced_date,
                p_start_date,
                p_end_date,
                0,
                sysdate,
                0,
                sysdate,
                a.bank_acct_id,
                billing_name,
                billing_attn,
                billing_address,
                billing_city,
                billing_zip,
                billing_state
            from
                invoice_parameters a,
                account            b,
                rate_plans         c
            where
                    b.entrp_id = nvl(p_entrp_id, b.entrp_id)
                and a.entity_id = b.entrp_id
                and a.entity_type = 'EMPLOYER'
                and c.entity_id = a.entity_id
                and a.rate_plan_id = c.rate_plan_id
                and c.entity_type = a.entity_type
                and c.status = 'A'
                and a.status = 'A'
                and a.invoice_type = 'FEE'
                and c.division_code is null
                and a.division_code is null
                and b.account_type = nvl(p_account_type, l_account_type)
                and c.rate_plan_type = 'INVOICE'
                and trunc(c.effective_date) <= p_end_date
                and ( c.effective_end_date is null
                      or c.effective_end_date >= p_end_date
                      or c.effective_end_date between p_start_date and p_end_date )
                and a.invoice_frequency <> 'QUARTERLY'
                and nvl(c.division_invoicing, 'N') = 'N'
                and a.payment_method = decode(l_account_type, 'HSA', 'DIRECT_DEPOSIT', 'LSA', 'DIRECT_DEPOSIT',
                                              a.payment_method);   -- Added LSA by Swamy for Ticket#9912 on 10/08/2021 /* No Invoices shud get generated for CHECK */


    -- division invoicing
        insert into ar_invoice (
            invoice_id,
            invoice_number,
            invoice_date,
            billing_date,
            invoice_due_date,
            invoice_type,
            invoice_amount,
            pending_amount,
            acc_id,
            acc_num,
            entity_id,
            entity_type,
            invoice_term,
            auto_pay,
            rate_plan_id,
            payment_method,
            batch_number,
            status,
            last_invoiced_date,
            start_date,
            end_date,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            bank_acct_id,
            billing_name,
            billing_attn,
            billing_address,
            billing_city,
            billing_zip,
            billing_state,
            division_code
        )
            select
                ar_invoice_seq.nextval,
                invoice_number_seq.nextval,
                nvl(p_billing_date,
                    to_date('10-'
                            || to_char(sysdate, 'MON-YYYY'),
                    'DD-MON-YYYY'))                        invoice_date,
                nvl(p_billing_date,
                    to_date('10-'
                            || to_char(sysdate, 'MON-YYYY'),
                    'DD-MON-YYYY'))                        billing_date,
                decode(p_billing_date,
                       null,
                       to_date('10-'
                               || to_char(sysdate, 'MON-YYYY'),
                       'DD-MON-YYYY'),
                       sysdate) + decode(a.payment_term,
                                         'NET7',
                                         7,
                                         'NET60',
                                         60,
                                         'NET30',
                                         30,
                                         'NET15',
                                         15,
                                         'NET90',
                                         90,
                                         'PIA',
                                         1,
                                         'IMMEDIATE',
                                         5,
                                         round(add_bus_days(sysdate, 4) - sysdate)) invoice_due_date,
                'AUTO',
                0,
                0,
                b.acc_id,
                b.acc_num,
                b.entrp_id,
                'EMPLOYER',
                a.payment_term,
                a.autopay,
                c.rate_plan_id,
                a.payment_method,
                l_batch_number,
                'DRAFT',
                a.last_invoiced_date,
                p_start_date,
                p_end_date,
                0,
                sysdate,
                0,
                sysdate,
                a.bank_acct_id,
                billing_name,
                billing_attn,
                billing_address,
                billing_city,
                billing_zip,
                billing_state,
                c.division_code
            from
                invoice_parameters a,
                account            b,
                rate_plans         c
            where
                    b.entrp_id = nvl(p_entrp_id, b.entrp_id)
                and a.entity_id = b.entrp_id
                and a.entity_type = 'EMPLOYER'
                and c.entity_id = a.entity_id
                and c.entity_type = a.entity_type
                and a.rate_plan_id = c.rate_plan_id
                and c.status = 'A'
                and a.status = 'A'
                and a.invoice_type = 'FEE'
                and b.account_type = nvl(p_account_type, l_account_type)
                and c.rate_plan_type = 'INVOICE'
                and trunc(c.effective_date) <= p_end_date
                and ( c.effective_end_date is null
                      or c.effective_end_date >= p_end_date
                      or c.effective_end_date between p_start_date and p_end_date )
                and a.invoice_frequency <> 'QUARTERLY'
                and nvl(c.division_invoicing, 'N') = 'Y'
                and c.division_code = a.division_code
                and c.division_code = nvl(p_division_code, c.division_code);


    -- Quarterly Invoice Generation
        insert into ar_invoice (
            invoice_id,
            invoice_number,
            invoice_date,
            billing_date,
            invoice_due_date,
            invoice_type,
            invoice_amount,
            pending_amount,
            acc_id,
            acc_num,
            entity_id,
            entity_type,
            invoice_term,
            auto_pay,
            rate_plan_id,
            payment_method,
            batch_number,
            status,
            last_invoiced_date,
            start_date,
            end_date,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            bank_acct_id,
            billing_name,
            billing_attn,
            billing_address,
            billing_city,
            billing_zip,
            billing_state
        )
            select
                ar_invoice_seq.nextval,
                invoice_number_seq.nextval,
                to_date('10-' || to_char(sysdate, 'MON-YYYY'),
                        'DD-MON-YYYY')                     invoice_date,
                to_date('10-' || to_char(sysdate, 'MON-YYYY'),
                        'DD-MON-YYYY')                     billing_date,
                decode(p_billing_date,
                       null,
                       to_date('10-'
                               || to_char(sysdate, 'MON-YYYY'),
                       'DD-MON-YYYY'),
                       sysdate) + decode(a.payment_term,
                                         'NET7',
                                         7,
                                         'NET60',
                                         60,
                                         'NET30',
                                         30,
                                         'NET15',
                                         15,
                                         'NET90',
                                         90,
                                         'PIA',
                                         1,
                                         'IMMEDIATE',
                                         5,
                                         round(add_bus_days(sysdate, 4) - sysdate)) invoice_due_date,
                'AUTO',
                0,
                0,
                b.acc_id,
                b.acc_num,
                b.entrp_id,
                'EMPLOYER',
                a.payment_term,
                a.autopay,
                c.rate_plan_id,
                a.payment_method,
                l_batch_number,
                'DRAFT',
                a.last_invoiced_date,
                add_months(p_end_date, -3) + 1,
                p_end_date,
                0,
                sysdate,
                0,
                sysdate,
                a.bank_acct_id,
                billing_name,
                billing_attn,
                billing_address,
                billing_city,
                billing_zip,
                billing_state
            from
                invoice_parameters a,
                account            b,
                rate_plans         c
            where
                    b.entrp_id = nvl(p_entrp_id, b.entrp_id)
                and a.entity_id = b.entrp_id
                and a.entity_type = 'EMPLOYER'
                and c.entity_id = a.entity_id
                and c.entity_type = a.entity_type
                and a.rate_plan_id = c.rate_plan_id
                and c.status = 'A'
                and a.status = 'A'
                and a.invoice_type = 'FEE'
                and b.account_type = nvl(p_account_type, l_account_type)  -- WE WILL NOT GENERATE ANY INVOICE FOR HSA
                and c.rate_plan_type = 'INVOICE'
                and trunc(c.effective_date) <= p_end_date
                and ( c.effective_end_date is null
                      or c.effective_end_date >= p_end_date )
                and nvl(c.division_invoicing, 'N') = 'N'
                and a.invoice_frequency = 'QUARTERLY'
                and trunc(
                    add_months(
                        nvl(a.last_invoiced_date,
                            trunc(c.effective_date)),
                        2
                    ),
                    'MM'
                ) = trunc(trunc(p_end_date, 'MM') + 1,
                          'MM');

        if ( l_account_type in ( 'HRA', 'FSA' )
             or l_account_type is null ) then
            process_hra_fsa_invoice(
                p_start_date    => p_start_date,
                p_end_date      => p_end_date,
                p_billing_date  => p_billing_date,
                p_entrp_id      => p_entrp_id,
                p_batch_number  => l_batch_number,
                x_error_status  => x_error_status,
                x_error_message => x_error_message,
                p_invoice_freq  =>
                                case
                                    when p_invoice_type in('SETUP', 'RENEWAL') then
                                        'ONETIME'
                                    else
                                        'MONTHLY'
                                end
            );
        elsif l_account_type in ( 'POP', 'ERISA_WRAP', 'FORM_5500', 'COBRA', 'CMP',
                                  'ACA', 'RB', 'FMLA' ) then
            process_pop_erisa_5500_inv(
                p_start_date        => p_start_date,
                p_end_date          => p_end_date,
                p_billing_date      => p_billing_date,
                p_entrp_id          => p_entrp_id,
                p_batch_number      => l_batch_number,
                p_invoice_frequency => p_invoice_type -- Added by Joshi for 11119
                ,
                x_error_status      => x_error_status,
                x_error_message     => x_error_message
            );
        elsif l_account_type = 'HSA' then
        -- We will be using this shortly
            process_hsa_invoice(
                p_start_date    => p_start_date,
                p_end_date      => p_end_date,
                p_billing_date  => p_billing_date,
                p_entrp_id      => p_entrp_id,
                p_batch_number  => l_batch_number,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            null;
            pc_log.log_error('PC_INVOICE.generate_invoice', 'Error message '
                                                            ||(x_error_message
                                                               || 'x_error_status :='
                                                               || x_error_status));

        elsif l_account_type = 'LSA' then    -- LSA Added by Swamy for Ticket#9912 on 10/08/2021

      -- For Monthly Invoice  Ticket#9912 on 10/08/2021
            if nvl(p_invoice_type, 'ONCE') = 'MONTHLY' then
                process_hsa_invoice(
                    p_start_date    => p_start_date,
                    p_end_date      => p_end_date,
                    p_billing_date  => p_billing_date,
                    p_entrp_id      => p_entrp_id,
                    p_batch_number  => l_batch_number,
                    x_error_status  => x_error_status,
                    x_error_message => x_error_message
                );

                pc_log.log_error('PC_INVOICE.generate_invoice', 'Error message '
                                                                ||(x_error_message
                                                                   || 'x_error_status :='
                                                                   || x_error_status));

            else
                pc_log.log_error('PC_INVOICE.generate_invoice', 'calling process_pop_erisa_5500_inv ' || l_batch_number);
           -- For One time setup fees invoice for Ticket#11047
                process_pop_erisa_5500_inv(
                    p_start_date    => p_start_date,
                    p_end_date      => p_end_date,
                    p_billing_date  => p_billing_date,
                    p_entrp_id      => p_entrp_id,
                    p_batch_number  => l_batch_number,
                    x_error_status  => x_error_status,
                    x_error_message => x_error_message
                );

            end if;
        end if;

 --   IF l_account_type not in ('POP','ERISA_WRAP','FORM_5500','COBRA','CMP','HSA','ACA', 'RB','FMLA','LSA') THEN    --LSA' Added by Swamy for Ticket#9912 on 10/08/2021 RB added by rprabu 8238 07/11/2019
        if l_account_type not in ( 'POP', 'ERISA_WRAP', 'FORM_5500', 'CMP', 'HSA',
                                   'ACA', 'RB', 'FMLA', 'LSA' ) then    --commented and added by joshi for 11468. Removed COBRA account type

       --Added by Joshi for 12239
            if ( l_account_type not in ( 'FSA', 'HRA' )
                 or (
                l_account_type in ( 'FSA', 'HRA' )
                and l_user_id is null
                and p_invoice_type = 'MONTHLY'
            ) ) then
                pc_log.log_error('PC_INVOICE.generate_invoice in deleting block l_user_id: ', l_user_id);                                   
           -- Deleting the invoices that is in draft status
                delete from ar_invoice
                where
                    not exists (
                        select
                            *
                        from
                            ar_invoice_lines
                        where
                            invoice_id = ar_invoice.invoice_id
                    )
                        and status = 'DRAFT'
                        and trunc(creation_date) = trunc(sysdate)
                        and batch_number = l_batch_number;

                if sql%rowcount > 0 then
                    x_batch_number := null;
                else
                    x_batch_number := l_batch_number;
                end if;

            else
                x_batch_number := l_batch_number;
            end if;
    --  pc_notifications.notify_takeover;
        else
            x_batch_number := l_batch_number;
        end if;

     -- Added by Joshi for 10573. update payment to Wire transfer for invoices > 100K
        if l_batch_number is not null then
            l_invoice_limit := pc_lookups.get_meaning('INVOICE_LIMIT', 'WIRE_TRANSFER_LIMIT');
            update ar_invoice
            set
                payment_method =
                    case
                        when invoice_amount >= l_invoice_limit then
                            'WIRE_TRANSFER'
                        else
                            payment_method
                    end,
                bank_acct_id =
                    case
                        when invoice_amount >= l_invoice_limit then
                            null
                        else
                            bank_acct_id
                    end
            where
                    status = 'GENERATED'
                and trunc(creation_date) = trunc(sysdate)
                and batch_number = l_batch_number;

        end if;
        -- code ends here 10573.

    exception
    --  WHEN INVOICE_EXCEPTION THEN
    --    RAISE_APPLICATION_ERROR('-20001',l_error_message);
    --    rollback;
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('PC_INVOICE.generate_invoice',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end generate_invoice;
 -- ERISA/POP/COBRA/5500/Compliance invoices are processed
 -- These invoices do not have special logic at all, Business sets up flat fee in the Invoice setup
 -- this procedures
    procedure process_pop_erisa_5500_inv (
        p_start_date        in date,
        p_end_date          in date,
        p_billing_date      in date default sysdate,
        p_entrp_id          in number,
        p_batch_number      in number,
        p_invoice_frequency varchar2 default null,
        x_error_status      out varchar2,
        x_error_message     out varchar2
    ) is

        l_exists             varchar2(1) := 'N';
        invoice_exception exception;
        l_return_status      varchar2(1);
        l_error_message      varchar2(32000);
        l_rate               number;
        l_quantity           number;
    --l_invoice_days    number;
   -- l_total           number;
        l_line_type          varchar2(50);
        l_fee_count          number := 0;
        l_inv_count          number := 0;
        l_invoice_id         number;
        l_invoice_line_id    number;
        l_total_inv_amount   number := 0;
        l_total_invoice_amt  number := 0;
        l_pers_id            number;
        l_pers_tbl           number_table;
        i                    number := 0;
        l_no_of_months       number := 0;
        l_total_month_amount number := 0;
        l_account_type       varchar2(30);
        l_effective_end_date date;  -- Added by Swamy for Ticket#11708
    begin
        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'P_BATCH_NUMBER ' || p_batch_number);
        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'P_START_DATE ' || p_start_date);
        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'P_END_DATE ' || p_end_date);
        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'P_INVOICE_FREQUENCY ' || p_invoice_frequency);
        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'P_BILLING_DATE ' || p_billing_date);
        for x in (
            select
                a.invoice_id,
                b.coverage_type,
                b.rate_code,
                b.rate_plan_cost,
                b.rate_basis,
                b.calculation_type,
                a.entity_id,
                c.plan_type,
                a.invoice_date,
                a.last_invoiced_date,
                b.description
                || ' '
                || c.reason_name                                rate_description,
                b.one_time_flag,
                b.minimum_range,
                a.start_date,
                a.end_date,
                a.billing_date,
                round(months_between(a.end_date, a.start_date)) no_of_months,
                a.division_code,
                a.rate_plan_id,
                a.entity_type,
                b.effective_date,
                b.charged_to
            from
                ar_invoice         a,
                rate_plan_detail   b,
                pay_reason         c,
                invoice_parameters d
            where
                    a.batch_number = p_batch_number
                and trunc(b.effective_date) <= p_start_date
                and ( b.effective_end_date is null
                      or b.effective_end_date >= p_end_date )
                and a.status = 'DRAFT'
                and a.entity_type = 'EMPLOYER'
                and a.rate_plan_id = b.rate_plan_id
                and c.status = 'A'
                and d.rate_plan_id = b.rate_plan_id
                and d.status = 'A'
                and d.invoice_type = 'FEE'
                and d.invoice_param_id = b.invoice_param_id
                and b.rate_code = to_char(c.reason_code)
        ) loop
            l_quantity := 0;
                 --l_invoice_days    := 0;
            l_line_type := null;
            l_total_inv_amount := 0;
            l_no_of_months := 0;
            pc_log.log_error('**1 PC_INVOICE.process_pop_erisa_5500_inv', 'invoice_id '
                                                                          || x.invoice_id
                                                                          || 'x.entity_id :='
                                                                          || x.entity_id);

            l_account_type := pc_account.get_account_type_from_entrp_id(x.entity_id);
            pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'invoice_id ' || x.invoice_id);
            if x.rate_basis = 'FLAT_FEE' then
                l_line_type := 'FLAT_FEE';
                l_quantity := 1;
                l_no_of_months := 1;
                l_total_inv_amount := x.rate_plan_cost;

                    -- Added by Joshi for #11119. when monthly setup for COBRA. discount and monthly rate code should not be end date.
                if p_invoice_frequency = 'MONTHLY' then

                             -- Added by Joshi for 11649
                    update rate_plan_detail
                    set
                        effective_end_date = nvl(p_billing_date,
                                                 trunc(sysdate)),
                        last_update_date = sysdate
                    where
                            rate_code = x.rate_code
                        and rate_plan_id = x.rate_plan_id
                        and one_time_flag = 'Y'
                        and effective_end_date is null
                        and rate_code not in ( 182, 183, 184, 265, 264 );
                              -- code ends here Joshi for 11649

                            -- Added by Joshi for 11294
                            -- Added status by Joshi for 11709
                    if x.entity_type = 'EMPLOYER' then
                        if l_account_type = 'COBRA' then
                                     /* commented code for 12091 by Joshi
                                    FOR MI IN ( SELECT *
                                                          FROM monthly_invoice_payment_detail
                                                       WHERE entrp_id  = X.entity_id
                                                            AND p_start_date BETWEEN plan_start_date AND plan_end_date )
                                   LOOP
                                            IF MI.PAYMENT_METHOD IS NOT NULL AND NVL(MI.STATUS, 'A' ) = 'A'  THEN
                                                UPDATE INVOICE_PARAMETERS
                                                       SET PAYMENT_METHOD =MI.PAYMENT_METHOD,
                                                              PAYMENT_TERM = DECODE( MI.PAYMENT_METHOD, 'DIRECT_DEPOSIT','IMMEDIATE','NET15'),
                                                              AUTOPAY    =   DECODE( MI.PAYMENT_METHOD, 'DIRECT_DEPOSIT','Y','N'),
                                                              bank_Acct_id =  MI.bank_acct_id
                                                WHERE ENTITY_TYPE = 'EMPLOYER'
                                                    AND  ENTITY_ID = x.entity_id
                                                    AND  invoice_type = 'FEE'
                                                    AND status = 'A';

                                                 UPDATE AR_INVOICE
                                                       SET PAYMENT_METHOD =MI.PAYMENT_METHOD,
                                                              INVOICE_TERM = DECODE( MI.PAYMENT_METHOD, 'DIRECT_DEPOSIT','IMMEDIATE','NET15'),
                                                              AUTO_PAY    =   DECODE( MI.PAYMENT_METHOD, 'DIRECT_DEPOSIT','Y','N'),
                                                              bank_Acct_id =  MI.bank_acct_id,
                                                               charged_to = MI.charged_to
                                                WHERE INVOICE_ID = X.INVOICE_ID;
                                                -- Added status by Joshi for 11709. if the bank is deleted. invoice should be generated with payment methd as
                                                -- 'Client initated ACH'
                                             ELSIF    MI.PAYMENT_METHOD IS NOT NULL AND NVL(MI.STATUS, 'A') = 'I'  THEN
                                               UPDATE AR_INVOICE
                                                      SET PAYMENT_METHOD ='ACH_PUSH',
                                                             INVOICE_TERM = 'NET15',
                                                             AUTO_PAY    =   'N',
                                                             bank_Acct_id =  NULL,
                                                            charged_to = MI.charged_to
                                                WHERE INVOICE_ID = X.INVOICE_ID;
                                     END IF;
                                   END LOOP;
                                   */

                                   -- 12091. modified the code to handle multiple payment records. monthly invoice payments can be changed 
                                  -- using invoice setting screen in SAM. 

                            for mi in (
                                select
                                    *
                                from
                                    monthly_invoice_payment_detail mio
                                where
                                        mio.entrp_id = x.entity_id
                                    and p_start_date between mio.plan_start_date and mio.plan_end_date
                                    and mio.monthly_payment_seq_no = (
                                        select
                                            max(mii.monthly_payment_seq_no)
                                        from
                                            monthly_invoice_payment_detail mii
                                        where
                                                mii.entrp_id = mio.entrp_id
                                            and mii.plan_start_date = mio.plan_start_date
                                            and mii.plan_end_date = mio.plan_end_date
                                    )
                            ) loop
                                if
                                    mi.payment_method is not null
                                    and nvl(mi.status, 'A') = 'A'
                                then -- commented a per 11801 Joshi
                                    update invoice_parameters
                                    set
                                        payment_method = mi.payment_method,
                                        payment_term = decode(mi.payment_method, 'DIRECT_DEPOSIT', 'IMMEDIATE', 'NET15'),
                                        autopay = decode(mi.payment_method, 'DIRECT_DEPOSIT', 'Y', 'N'),
                                        bank_acct_id = mi.bank_acct_id
                                    where
                                            entity_type = 'EMPLOYER'
                                        and entity_id = x.entity_id
                                        and invoice_type = 'FEE'
                                        and status = 'A';

                                    update ar_invoice
                                    set
                                        payment_method = mi.payment_method,
                                        invoice_term = decode(mi.payment_method, 'DIRECT_DEPOSIT', 'IMMEDIATE', 'NET15'),
                                        auto_pay = decode(mi.payment_method, 'DIRECT_DEPOSIT', 'Y', 'N'),
                                        bank_acct_id = mi.bank_acct_id,
                                        charged_to = mi.charged_to
                                    where
                                        invoice_id = x.invoice_id;

                                elsif
                                    mi.payment_method is not null
                                    and nvl(mi.status, 'A') = 'I'
                                then
                                    update ar_invoice
                                    set
                                        payment_method = 'ACH_PUSH',
                                        invoice_term = 'NET15',
                                        auto_pay = 'N',
                                        bank_acct_id = null,
                                        charged_to = mi.charged_to
                                    where
                                        invoice_id = x.invoice_id;

                                end if;
                            end loop;

                        end if;

                    end if;
                            -- code ends here  by Joshi for 11294

                else
                    if l_account_type = 'FORM_5500' then   -- Added by Swamy for Ticket#11708
                        l_effective_end_date := nvl(p_start_date, p_billing_date);
                    else
                        l_effective_end_date := p_billing_date;
                    end if;

                    update rate_plan_detail
                    set
                        effective_end_date = l_effective_end_date  -- P_BILLING_DATE  -- Added by Swamy for Ticket#11708
                        ,
                        last_update_date = sysdate
                    where
                            rate_code = x.rate_code
                        and rate_plan_id = x.rate_plan_id
                        and one_time_flag = 'Y'
                        and effective_end_date is null
                        and rate_code not in ( 182, 183, 184 );

                    if l_account_type <> 'COBRA' then    -- Added by Joshi for 12356.
                        update ar_invoice
                        set
                            charged_to = x.charged_to
                        where
                            invoice_id = x.invoice_id;

                    end if;

                end if;

                if
                    l_quantity <> 0
                    and l_total_inv_amount > 0
                    and x.rate_code not in ( 264, 265, 266, 267 )
                then

                        -- Added by Joshi for 11294
                    if l_account_type = 'COBRA' then

                         --   IF P_INVOICE_FREQUENCY = 'ONCE'  THEN
                        if p_invoice_frequency in ( 'SETUP', 'RENEWAL', 'ONCE' ) then --commented above added by Joshi for 12356.

                            if x.effective_date >= p_start_date then
                                pc_invoice.insert_invoice_line(
                                    p_invoice_id        => x.invoice_id,
                                    p_invoice_line_type => l_line_type,
                                    p_rate_code         => x.rate_code,
                                    p_description       => x.rate_description,
                                    p_quantity          => l_quantity,
                                    p_no_of_months      => l_no_of_months,
                                    p_rate_cost         => x.rate_plan_cost,
                                    p_total_cost        => l_total_inv_amount,
                                    p_batch_number      => p_batch_number,
                                    x_invoice_line_id   => l_invoice_line_id
                                );

                                pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'charged_to ' || x.charged_to);                    

                                       -- Added by Joshi for 12356.  
                                update ar_invoice
                                set
                                    charged_to = x.charged_to
                                where
                                    invoice_id = x.invoice_id;

                            end if;

                        else
                            pc_invoice.insert_invoice_line(
                                p_invoice_id        => x.invoice_id,
                                p_invoice_line_type => l_line_type,
                                p_rate_code         => x.rate_code,
                                p_description       => x.rate_description,
                                p_quantity          => l_quantity,
                                p_no_of_months      => l_no_of_months,
                                p_rate_cost         => x.rate_plan_cost,
                                p_total_cost        => l_total_inv_amount,
                                p_batch_number      => p_batch_number,
                                x_invoice_line_id   => l_invoice_line_id
                            );
                        end if;
                    else
                        pc_invoice.insert_invoice_line(
                            p_invoice_id        => x.invoice_id,
                            p_invoice_line_type => l_line_type,
                            p_rate_code         => x.rate_code,
                            p_description       => x.rate_description,
                            p_quantity          => l_quantity,
                            p_no_of_months      => l_no_of_months,
                            p_rate_cost         => x.rate_plan_cost,
                            p_total_cost        => l_total_inv_amount,
                            p_batch_number      => p_batch_number,
                            x_invoice_line_id   => l_invoice_line_id
                        );
                    end if;

                    pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'l_invoice_line_id ' || l_invoice_line_id);
                end if;

                if
                    l_quantity <> 0
                    and x.rate_code in ( 264, 265, 266, 267 )
                then
                    pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'x.rate_code ' || x.rate_code);
                    pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', ' X.rate_plan_cost ' || x.rate_plan_cost);
                    pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'l_total_inv_amount ' || l_total_inv_amount);
                  --     pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv','l_invoice_line_id '||l_invoice_line_id);

                    pc_invoice.insert_invoice_line(
                        p_invoice_id        => x.invoice_id,
                        p_invoice_line_type => l_line_type,
                        p_rate_code         => x.rate_code,
                        p_description       => x.rate_description,
                        p_quantity          => l_quantity,
                        p_no_of_months      => l_no_of_months,
                        p_rate_cost         =>(x.rate_plan_cost * - 1),
                        p_total_cost        => null,
                        p_batch_number      => p_batch_number,
                        x_invoice_line_id   => l_invoice_line_id
                    );

                    pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'l_invoice_line_id ' || l_invoice_line_id);
                end if;

            end if;

        end loop; --rate_plan_detail/rate_code loop
   --    END LOOP;

        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', '***********1 ');
        for x in (
            select
                batch_number
            from
                ar_invoice
            where
                    batch_number = p_batch_number
                and invoice_reason = 'FEE'
                and status in ( 'GENERATED', 'DRAFT' )
        ) loop
            apply_service_charge(x.batch_number);
        end loop;

        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', '***********2 ');
        apply_tax(p_batch_number);
        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', '***********3 ');
        for x in (
            select
                ar.invoice_id,
                ar.invoice_date,
                ar.entity_id,
                ar.entity_type,
                ar.billing_date,
                a.invoice_type,
                sum(arl.total_line_amount) invoice_amount,
                ar.rate_plan_id
            from
                ar_invoice         ar,
                ar_invoice_lines   arl,
                invoice_parameters a,
                pay_reason         pr
            where
                    ar.batch_number = p_batch_number
                and ar.invoice_id = arl.invoice_id
                and a.entity_id = ar.entity_id
                and a.rate_plan_id = ar.rate_plan_id
                and arl.rate_code = to_char(pr.reason_code)
                and a.invoice_type = ar.invoice_reason
                and ar.status = 'DRAFT'
                and a.status = 'A'
                and a.invoice_type = 'FEE'
                and arl.status = 'DRAFT'
            group by
                ar.invoice_id,
                ar.invoice_date,
                ar.entity_id,
                ar.entity_type,
                ar.billing_date,
                a.invoice_type,
                ar.rate_plan_id
        ) loop
            update ar_invoice
            set
                status = 'GENERATED',
                invoice_amount = x.invoice_amount,
                pending_amount = x.invoice_amount,
                last_update_date = sysdate,
                last_updated_by = 0
            where
                invoice_id = x.invoice_id;

            update ar_invoice_lines
            set
                status = 'GENERATED',
                last_update_date = sysdate,
                last_updated_by = 0
            where
                invoice_id = x.invoice_id;

                         -- Added by Joshi for 8471. update rate_effective_end_date once all fee
                         -- is collected
            pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'P_BILLING_DATE ' || p_billing_date);
            pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'P_START_DATE ' || p_start_date);
            if p_invoice_frequency = 'MONTHLY' then

                             -- For Ticket#12198 by Swamy 10062024
                for y in (
                    select
                        max(plan_start_date) plan_start_date,
                        max(plan_end_date)   plan_end_date
                    from
                        ben_plan_enrollment_setup b,
                        account                   a
                    where
                            a.entrp_id = x.entity_id
                        and a.acc_id = b.acc_id
                        and account_type = 'COBRA'
                        and trunc(b.plan_end_date, 'MM') <= trunc(p_start_date)
                ) loop
                    pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'Y.PLAN_START_DATE ' || y.plan_start_date);
                    pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv', 'Y.PLAN_END_DATE ' || y.plan_end_date);
                    if
                        y.plan_start_date is not null
                        and y.plan_end_date is not null
                    then
                        pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv updating ', 'Y.PLAN_END_DATE ' || y.plan_end_date);
                        update rate_plan_detail
                        set
                            effective_end_date = last_day(y.plan_end_date),
                            last_update_date = sysdate
                        where
                            rate_code in ( 182, 183, 184, 265, 264 )
                            and rate_plan_id = x.rate_plan_id
                            and one_time_flag = 'N'
                            and effective_end_date is null
                            and trunc(effective_date) <= y.plan_start_date;

                    end if;
                            -- Commented below and replaced above for ticket#12198 by Swamy 10062024
                            /*FOR Y in ( SELECT PLAN_START_DATE , PLAN_END_DATE, ACCOUNT_TYPE
                                         FROM BEN_PLAN_ENROLLMENT_SETUP B, ACCOUNT A
                                        WHERE A.ENTRP_ID = X.ENTITY_ID
                                          AND A.ACC_ID = B.ACC_ID
                                          AND TRUNC(P_START_DATE)  BETWEEN PLAN_START_DATE AND PLAN_END_DATE )

                             LOOP

                              pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv','Y.PLAN_START_DATE '||Y.PLAN_START_DATE);
                              pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv','Y.PLAN_END_DATE '||Y.PLAN_END_DATE);

                                IF Y.ACCOUNT_TYPE = 'COBRA' THEN

                                    -- get the base price.
                                   SELECT   SUM(D.RATE_PLAN_COST) TOTAL_MONTH_AMOUNT
                                      INTO  L_TOTAL_MONTH_AMOUNT
                                      FROM   INVOICE_PARAMETERS A
                                            , ACCOUNT B
                                            , RATE_PLANS C
                                            , RATE_PLAN_DETAIL D
                                      WHERE  B.entrp_id = X.ENTITY_ID
                                        AND A.ENTITY_ID = B.entrp_id
                                        AND A.ENTITY_TYPE = 'EMPLOYER'
                                        AND C.ENTITY_ID = A.ENTITY_ID
                                        AND A.RATE_PLAN_ID = C.RATE_PLAN_ID
                                        AND C.ENTITY_TYPE = A.ENTITY_TYPE
                                        AND C.STATUS = 'A'
                                        AND A.STATUS = 'A'
                                        AND C.RATE_PLAN_ID = D.RATE_PLAN_ID
                                        and A.invoice_type = 'FEE'
                                        AND B.ACCOUNT_TYPE = 'COBRA'
                                        AND C.RATE_PLAN_TYPE = 'INVOICE'
                                        AND D.RATE_CODE IN (182,183,184) -- Added by Joshi for enhancment (8982)
                                        AND A.PAYMENT_METHOD = 'DIRECT_DEPOSIT'
                                        AND A.INVOICE_FREQUENCY = 'MONTHLY'
                                        AND TRUNC(D.EFFECTIVE_DATE) BETWEEN Y.PLAN_START_DATE AND Y.PLAN_END_DATE ;

                                 pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv','L_TOTAL_MONTH_AMOUNT '||L_TOTAL_MONTH_AMOUNT);

                                    SELECT ROUND(SUM(NVL(ARL.TOTAL_LINE_AMOUNT,0)) , 2)
                                      INTO L_TOTAL_INVOICE_AMT
                                      FROM AR_INVOICE AR, AR_INVOICE_LINES ARL
                                     WHERE AR.INVOICE_ID = ARL.INVOICE_ID
                                       AND ARL.RATE_CODE in (182, 183, 184)
                                       AND AR.ENTITY_ID = X.ENTITY_ID
                                       AND TRUNC(AR.INVOICE_DATE) BETWEEN Y.PLAN_START_DATE AND Y.PLAN_END_DATE ;

                                pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv','L_TOTAL_INVOICE_AMT '||L_TOTAL_INVOICE_AMT);
                                pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv','L_TOTAL_AMOUNT '||ROUND(L_TOTAL_MONTH_AMOUNT*12, 2) );

                                       IF L_TOTAL_INVOICE_AMT >= ROUND(L_TOTAL_MONTH_AMOUNT*12, 2) THEN

                                          UPDATE RATE_PLAN_DETAIL
                                             SET
                                                  EFFECTIVE_END_DATE = LAST_DAY(Y.PLAN_END_DATE) -- Added by Joshi for 11294.
                                                --EFFECTIVE_END_DATE = NVL( P_BILLING_DATE, X.BILLING_DATE)
                                               , last_update_date  = SYSDATE
                                           WHERE RATE_CODE in (182, 183, 184,265,264)
                                             AND rate_plan_id = x.rate_plan_id
                                             AND ONE_TIME_FLAG = 'N'
                                             AND EFFECTIVE_END_DATE IS NULL
                                             AND TRUNC(EFFECTIVE_DATE) BETWEEN Y.PLAN_START_DATE AND Y.PLAN_END_DATE ; -- Added by Joshi 8634 ;
                                       END IF;
                                  END IF;*/
                end loop;
            else
                           -- set last invoiced date
                update invoice_parameters
                set
                    last_invoiced_date = x.billing_date
                where
                        entity_id = x.entity_id
                    and entity_type = 'EMPLOYER'
                    and invoice_type = x.invoice_type
                    and rate_plan_id = x.rate_plan_id;

            end if;
                        -- code ends here Joshi for 8471
        end loop;

        commit;
        x_error_status := 'S';
    exception
    --  WHEN INVOICE_EXCEPTION THEN
    --    RAISE_APPLICATION_ERROR('-20001',l_error_message);
    --    rollback;
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            rollback;
    end process_pop_erisa_5500_inv;
 -- We will pulling the active members of the groups and check their monthly fee setup in the invoice setup
 -- We will charge the fees based on that
    procedure process_hsa_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_exists           varchar2(1) := 'N';
        invoice_exception exception;
        l_return_status    varchar2(1);
        l_error_message    varchar2(32000);
        l_rate             number;
        l_quantity         number;
    --l_invoice_days    number;
   -- l_total           number;
        l_line_type        varchar2(50);
        l_fee_count        number := 0;
        l_inv_count        number := 0;
        l_invoice_id       number;
        l_invoice_line_id  number;
        l_total_inv_amount number := 0;
        l_pers_id          number;
        l_pers_tbl         number_table;
        i                  number := 0;
        l_no_of_months     number := 0;
        l_plan_code        number; /*Ticket* 7391 */
        l_plan_cost        number;
    begin
        for x in (
            select
                invoice_id,
                b.entrp_id,
                invoice_date,
                last_invoiced_date
            from
                ar_invoice a,
                enterprise b
            where
                    batch_number = p_batch_number
                and a.entity_id = b.entrp_id
        ) loop
            x_error_status := 'S';
            x_error_message := null;
                     /*Ticket* 7391 */
            for xx in (
                select
                    plan_code,
                    fee_maint,
                    account_type,
                    entrp_id
                from
                    account
                where
                        entrp_id = x.entrp_id
                    and pers_id is null
            ) loop
                l_plan_code := xx.plan_code;
                -- l_plan_cost := XX.FEE_MAINT;   -- Commented by Swamy for Ticket#10104 on 21/09/2021
                -- Added by Swamy for Ticket#10104 on 21/09/2021
                -- For LSA To get the monthly fee the system will check the setting at invoice level for monthly fee, if 0 then it will check at the plan level and if it is 0 then default of $5 will be taken.
                if xx.account_type = 'LSA' then
                    if pc_plan.fcustom_fee_value(x.entrp_id, 2) <> 0 then
                        l_plan_cost := pc_plan.fcustom_fee_value(x.entrp_id, 2);
                    elsif pc_plan.fee_value(xx.plan_code, 2) <> 0 then
                        l_plan_cost := pc_plan.fee_value(xx.plan_code, 2);
                    else
                        l_plan_cost := 5;
                    end if;

                else
                    l_plan_cost := xx.fee_maint;
                end if;

            end loop;

            pc_log.log_error('PC_INVOICE.process_hsa_invoice', 'Calling Process Distributions, batch_number '
                                                               || p_batch_number
                                                               || ' emplr id '
                                                               || x.entrp_id
                                                               || ' invoice id '
                                                               || x.invoice_id
                                                               || ' invoice date '
                                                               || sysdate
                                                               || ' l_plan_cost := '
                                                               || l_plan_cost);

            for xx in (
                select
                    level,
                    add_months(
                        trunc(p_start_date, 'MM'),
                        1 * level - 1
                    )      start_date
                                    -- ,   LAST_DAY(add_months (trunc (p_start_date, 'MM'), 1*Level -1)) END_DATE
                    ,
                    add_months(
                        trunc(p_start_date, 'MM'),
                        1 * level - 1
                    ) + 27 end_date   /*Ticket#7391 .End date shud be 27th of every month*/
                from
                    dual
                connect by
                    level <= months_between(p_end_date + 1, p_start_date)
                order by
                    end_date
            ) loop
                proc_hsa_active_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);
                  /*Ticket 7391 Pass ER plan code */
                proc_hsa_distribution_summary(x.invoice_id, xx.start_date, xx.end_date, l_plan_code);
                 -- proc_hsa_distribution_summary(x.invoice_id,  xX.START_DATE, xx.END_DATE,l_plan_code );

            end loop;

        end loop;

        for x in (
            select
                a.invoice_id
                   -- ,  B.COVERAGE_TYPE
                   -- ,  B.RATE_CODE
                   -- ,  B.RATE_PLAN_COST
                  --  ,  B.RATE_BASIS
                   -- ,  B.CALCULATION_TYPE
                ,
                a.entity_id,
                c.plan_type,
                a.invoice_date,
                a.last_invoiced_date,
                c.reason_name                                   rate_description
                    --,  B.ONE_TIME_FLAG
                    --,  B.minimum_range
                ,
                a.start_date,
                a.end_date,
                round(months_between(a.end_date, a.start_date)) no_of_months,
                a.division_code
            from
                ar_invoice         a,
                invoice_parameters b,
                pay_reason         c
            where
                    a.batch_number = p_batch_number
                   --  AND    TRUNC(B.EFFECTIVE_DATE) <= P_START_DATE
                    --AND    (B.EFFECTIVE_END_DATE IS NULL OR B.EFFECTIVE_END_DATE >= P_END_DATE)
                and a.status = 'DRAFT'
                and a.entity_type = 'EMPLOYER'
                and b.entity_id = a.entity_id
                and c.status = 'A'
                and b.payment_method = 'DIRECT_DEPOSIT'
                and b.invoice_type = 'FEE'
                and b.invoice_frequency = 'MONTHLY'
                and to_char(c.reason_code) = 2
        ) --Monthly Fee
         loop
            l_pers_tbl := number_table();
            l_total_inv_amount := 0;
            for xx in (
                select
                    sum(rate_amount) inv_cost,
                    count(*)         quantity
                from
                    invoice_distribution_summary ids
                where
                        ids.invoice_id = x.invoice_id
                                 --  and    ids.invoice_kind = X.rate_basis
                    and ids.rate_code = 2  --rate code
                    and x.division_code is null
                    or ( x.division_code is not null
                         and ids.division_code = x.division_code )
            )/*Ticket#7391 */ loop
                             -- pc_log.log_error('PC_INVOICE.process_hsa_invoice','Rate basis '||x.rate_basis);
                pc_log.log_error('PC_INVOICE.process_hsa_invoice', 'xx.quantity ' || xx.quantity);
                pc_log.log_error('PC_INVOICE.process_hsa_invoice', 'xx.inv_cost ' || xx.inv_cost);
                l_line_type := 'ACTIVE';
                l_quantity := xx.quantity;
                l_no_of_months := 1;
                l_total_inv_amount := l_total_inv_amount + nvl(xx.inv_cost, 0);
                              --l_plan_cost := Pc_Plan.fee_value(l_plan_code, 2);
            end loop;
                   -- end if;

                     -- Added by Josh for 12427
            for xx in (
                select
                    plan_code,
                    fee_maint,
                    account_type,
                    entrp_id
                from
                    account
                where
                        entrp_id = x.entity_id
                    and pers_id is null
            ) loop
                l_plan_code := xx.plan_code;
                l_plan_cost := 0;
                if xx.account_type = 'LSA' then
                    if pc_plan.fcustom_fee_value(xx.entrp_id, 2) <> 0 then
                        l_plan_cost := pc_plan.fcustom_fee_value(xx.entrp_id, 2);
                    elsif pc_plan.fee_value(xx.plan_code, 2) <> 0 then
                        l_plan_cost := pc_plan.fee_value(xx.plan_code, 2);
                    else
                        l_plan_cost := 5;
                    end if;
                else
                    l_plan_cost := xx.fee_maint;
                end if;

            end loop;
                    -- code ends here 12427.

            if l_quantity <> 0 then
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => l_line_type,
                    p_rate_code         => 2,
                    p_description       => x.rate_description,
                    p_quantity          => l_quantity,
                    p_no_of_months      => l_no_of_months,
                    p_rate_cost         => l_plan_cost,--X.rate_plan_cost,???ASK
                    p_total_cost        => l_total_inv_amount,
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );

                update invoice_distribution_summary
                set
                    invoice_line_id = l_invoice_line_id
                where
                        rate_code = 2
                    and invoice_kind = 'ACTIVE'
                    and invoice_id = x.invoice_id;

            end if;

        end loop;

        for x in (
            select
                ar.invoice_id,
                ar.invoice_date,
                ar.entity_id,
                ar.entity_type,
                ar.billing_date,
                a.invoice_type,
                sum(arl.total_line_amount) invoice_amount,
                a.rate_plan_id
            from
                ar_invoice         ar,
                ar_invoice_lines   arl,
                invoice_parameters a,
                pay_reason         pr
            where
                    ar.batch_number = p_batch_number
                and ar.invoice_id = arl.invoice_id
                and a.entity_id = ar.entity_id
                and a.rate_plan_id = ar.rate_plan_id
                and arl.rate_code = to_char(pr.reason_code)
                and ar.invoice_reason = a.invoice_type
                and ar.payment_method = a.payment_method  /*Ticket#7391 */
                and ar.status = 'DRAFT'
                and a.status = 'A'
                and arl.status = 'DRAFT'
            group by
                ar.invoice_id,
                ar.invoice_date,
                ar.entity_id,
                ar.entity_type,
                ar.billing_date,
                a.invoice_type,
                a.rate_plan_id
            order by
                1
        ) loop
            update ar_invoice
            set
                status = 'GENERATED',
                invoice_amount = x.invoice_amount,
                pending_amount = x.invoice_amount,
                last_update_date = sysdate,
                last_updated_by = 0
            where
                invoice_id = x.invoice_id;

            update ar_invoice_lines
            set
                status = 'GENERATED',
                last_update_date = sysdate,
                last_updated_by = 0
            where
                invoice_id = x.invoice_id;

                        -- set last invoiced date
            update invoice_parameters
            set
                last_invoiced_date = x.billing_date
            where
                    entity_id = x.entity_id
                and entity_type = 'EMPLOYER'
                and invoice_type = x.invoice_type
                and rate_plan_id = x.rate_plan_id;

        end loop;

    end process_hsa_invoice;
 -- This is one of the most complicated procedures of all the invoice procedures
 -- This procedure first collects the data for various fees
 -- then it aggrgates the data into invoice distribution summary based on
 -- different rules that is recorded in pier under invoice project as Invoice FAQ
 -- The rules are too many to list here
    procedure process_hra_fsa_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2,
        p_invoice_freq  in varchar2 default 'MONTHLY'
    ) is

        l_exists             varchar2(1) := 'N';
        invoice_exception exception;
        l_return_status      varchar2(1);
        l_error_message      varchar2(32000);
        l_rate               number;
        l_quantity           number;
    --l_invoice_days    number;
   -- l_total           number;
        l_line_type          varchar2(50);
        l_fee_count          number := 0;
        l_renewal_count      number := 0;
        l_hra_renew_count    number := 0;
        l_fsa_renew_count    number := 0;
        l_inv_count          number := 0;
        l_invoice_id         number;
        l_invoice_line_id    number;
        l_total_inv_amount   number := 0;
        l_pers_tbl           number_table;
        l_pers_id            number;
        l_a_pers_tbl         number_table;
        l_a_quantity         number := 0;
        l_a_line_type        varchar2(30) := null;
        l_a_total_inv_amount number := 0;
        l_a_no_of_months     number := 0;
        l_at_pers_tbl        number_table;
        l_t_quantity         number := 0;
        l_t_line_type        varchar2(30) := null;
        l_t_total_inv_amount number := 0;
        l_t_no_of_months     number := 0;
        l_tot_adjustment     number := 0;
        l_invoice_amount     number := 0;
        i                    number := 0;
        l_no_of_months       number := 0;
    begin
        pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'Calling Process Distributions, batch_number ' || p_batch_number);
        pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'Calling Process Distributions, P_INVOICE_FREQ ' || p_invoice_freq);
        pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice',
                         'Calling Process Distributions, P_START_DATE ' || to_char(p_start_date, 'mm/dd/yyyy'));
        pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice',
                         'Calling Process Distributions, P_END_DATE ' || to_char(p_end_date, 'mm/dd/yyyy'));
        for x in (
            select
                invoice_id,
                b.entrp_id,
                invoice_date,
                last_invoiced_date,
                start_date,
                end_date,
                a.division_code
            from
                ar_invoice a,
                enterprise b
            where
                    batch_number = p_batch_number
                and a.entity_id = b.entrp_id
        ) loop
            x_error_status := 'S';
            x_error_message := null;
            g_division_code := null;
            pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'In the loop');
            pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'Calling Process Distributions, batch_number '
                                                                   || p_batch_number
                                                                   || ' emplr id '
                                                                   || x.entrp_id
                                                                   || ' invoice id '
                                                                   || x.invoice_id
                                                                   || ' invoice date '
                                                                   || sysdate
                                                                   || 'g_division_code '
                                                                   || g_division_code);

             -- For Quarterly invoices, we have to run for every month and then aggregate all into everything
             --
            g_division_code := x.division_code;
            pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'g_division_code '
                                                                   || g_division_code
                                                                   || 'P_INVOICE_FREQ :='
                                                                   || p_invoice_freq
                                                                   || 'X.start_date :='
                                                                   || x.start_date
                                                                   || 'X.end_date :='
                                                                   || x.end_date);

            if p_invoice_freq = 'MONTHLY' then

             -- Added by Joshi for 11294
             -- Added status by Joshi for 11709
                -- commneted by Joshi for 12091.
                /*
                    FOR MI IN ( select *
                                          from monthly_invoice_payment_detail
                                       where entrp_id  = x.entrp_id
                                            and X.start_date between plan_start_date and plan_end_date )
                   LOOP
                           IF MI.PAYMENT_METHOD IS NOT NULL AND NVL(MI.STATUS , 'A') = 'A'  THEN

                                UPDATE INVOICE_PARAMETERS
                                       SET PAYMENT_METHOD =MI.PAYMENT_METHOD,
                                              PAYMENT_TERM = DECODE( MI.PAYMENT_METHOD, 'DIRECT_DEPOSIT','IMMEDIATE','NET15'),
                                              AUTOPAY    =   DECODE( MI.PAYMENT_METHOD, 'DIRECT_DEPOSIT','Y','N'),
                                              BANK_ACCT_ID =  MI.bank_acct_id
                                WHERE ENTITY_TYPE = 'EMPLOYER'
                                    AND  ENTITY_ID = x.entrp_id
                                    AND  INVOICE_TYPE = 'FEE'
                                    AND STATUS = 'A';

                              UPDATE AR_INVOICE
                                     SET PAYMENT_METHOD =MI.PAYMENT_METHOD,
                                            INVOICE_TERM = DECODE( MI.PAYMENT_METHOD, 'DIRECT_DEPOSIT','IMMEDIATE','NET15'),
                                            AUTO_PAY    =   DECODE( MI.PAYMENT_METHOD, 'DIRECT_DEPOSIT','Y','N'),
                                            BANK_ACCT_ID =  MI.bank_acct_id,
                                            CHARGED_TO = MI.charged_to-- added by Joshi for solving charged_to problem.
                               WHERE INVOICE_ID = X.INVOICE_ID;

                            -- Added status by Joshi for 11709. if the bank is deleted. invoice should be generated with payment methd as
                            -- 'Client initated ACH'
                            ELSIF    MI.PAYMENT_METHOD IS NOT NULL AND NVL(MI.STATUS, 'A' ) = 'I'  THEN
                                   UPDATE AR_INVOICE
                                          SET PAYMENT_METHOD ='ACH_PUSH',
                                                 INVOICE_TERM = 'NET15',
                                                 AUTO_PAY    =   'N',
                                                 BANK_ACCT_ID =  NULL,
                                                 CHARGED_TO = MI.charged_to
                                    WHERE INVOICE_ID = X.INVOICE_ID;
                            END IF;
                   END LOOP;
                -- code ends here  by Joshi for 11294
                */

                    -- 12091. modified the code to handle multiple payment records. monthly invoice payments can be changed 
                    -- using invoice setting screen in SAM. 

                for mi in (
                    select
                        *
                    from
                        monthly_invoice_payment_detail mio
                    where
                            mio.entrp_id = x.entrp_id
                        and x.start_date between mio.plan_start_date and mio.plan_end_date
                        and mio.monthly_payment_seq_no = (
                            select
                                max(mii.monthly_payment_seq_no)
                            from
                                monthly_invoice_payment_detail mii
                            where
                                    mii.plan_start_date = mio.plan_start_date
                                and mii.plan_end_date = mio.plan_end_date
                        )
                ) loop
                    if
                        mi.payment_method is not null
                        and nvl(mi.status, 'A') = 'A'
                    then -- commented a per 11801 Joshi

                        update invoice_parameters
                        set
                            payment_method = mi.payment_method,
                            payment_term = decode(mi.payment_method, 'DIRECT_DEPOSIT', 'IMMEDIATE', 'NET15'),
                            autopay = decode(mi.payment_method, 'DIRECT_DEPOSIT', 'Y', 'N'),
                            bank_acct_id = mi.bank_acct_id
                        where
                                entity_type = 'EMPLOYER'
                            and entity_id = x.entrp_id
                            and invoice_type = 'FEE'
                            and status = 'A';

                        update ar_invoice
                        set
                            payment_method = mi.payment_method,
                            invoice_term = decode(mi.payment_method, 'DIRECT_DEPOSIT', 'IMMEDIATE', 'NET15'),
                            auto_pay = decode(mi.payment_method, 'DIRECT_DEPOSIT', 'Y', 'N'),
                            bank_acct_id = mi.bank_acct_id,
                            charged_to = mi.charged_to-- added by Joshi for solving charged_to problem.
                        where
                            invoice_id = x.invoice_id;

                    elsif
                        mi.payment_method is not null
                        and nvl(mi.status, 'A') = 'I'
                    then
                        update ar_invoice
                        set
                            payment_method = 'ACH_PUSH',
                            invoice_term = 'NET15',
                            auto_pay = 'N',
                            bank_acct_id = null,
                            charged_to = mi.charged_to
                        where
                            invoice_id = x.invoice_id;

                    end if;
                end loop;

                for xx in (
                    select
                        level,
                        add_months(
                            trunc(x.start_date, 'MM'),
                            1 * level - 1
                        )  start_date,
                        last_day(add_months(
                            trunc(x.start_date, 'MM'),
                            1 * level - 1
                        )) end_date
                    from
                        dual
                    connect by
                        level <= months_between(x.end_date + 1, x.start_date)
                    order by
                        end_date
                ) loop
                    pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'START DATE '
                                                                           || xx.start_date
                                                                           || ' END DATE '
                                                                           || xx.end_date);

                    -- Data Collection Procedure

                    -- All the Active participants are collected here
                    proc_active_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);
                    -- All the runout participants are collected here
                    proc_runout_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);
                    -- All the termed participants are collected here

                    proc_term_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);
                      -- All the debit/atm fees are collected here

                    proc_debit_card_charge_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);
                      -- All the debit card issuance participants are collected here

                    proc_debit_card_issuance_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);
                       -- All the debit card lost/stolen card order participants are collected here

                    proc_lost_stolen_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);
                       -- All the EOB Charges  are collected here, but we have waived off now but still if we decide
                       -- to charge we could continue

                    proc_eob_charge_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);

                    -- San Francisco Ordinance Maintenance Charges
                    proc_sf_ord_dist(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);

                    -- We have to collect the term data only once even for Quarterly Invoice
                    if xx.level = 1 then
                        proc_term_credit(x.invoice_id, x.entrp_id, p_start_date, p_end_date);
                    end if;

                    -- When the enrollment is back dated then we should collect the data once and
                    -- find the number of months between effective date and current invoice month
                    -- and charge
                    if xx.level = 1 then
                        proc_active_adj_dist(x.invoice_id, x.entrp_id, p_start_date, p_end_date);
                    end if;

                   -- proc_sf_ord_dist(x.invoice_id,x.entrp_id,  xX.START_DATE, xx.END_DATE );

                    -- This is the procedure that aggregates the data based on rules
                    proc_distribution_summary(x.invoice_id, x.entrp_id, xx.start_date, xx.end_date);

                end loop;

            end if;

            l_exists := 'Y';
            l_invoice_id := x.invoice_id;
        end loop;

        pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'Calling Process Distributions, l_exists ' || l_exists);
        if l_exists = 'N' then
            l_error_message := 'No Invoice Generated';
            raise invoice_exception;
        end if;
   -- Active , Runout, Card Lines
        for x in (
            select
                a.invoice_id,
                b.coverage_type,
                b.rate_code,
                b.rate_plan_cost,
                b.rate_basis,
                b.rate_plan_id,
                b.calculation_type,
                a.entity_id,
                c.plan_type,
                a.invoice_date,
                a.last_invoiced_date,
                c.reason_name                                   rate_description,
                b.one_time_flag,
                b.minimum_range,
                a.start_date,
                a.end_date,
                round(months_between(a.end_date, a.start_date)) no_of_months,
                b.charged_to,
                b.description -- Added by Joshi for 12664
            from
                ar_invoice         a,
                rate_plan_detail   b,
                pay_reason         c,
                invoice_parameters d
            where
                    a.batch_number = p_batch_number
                and c.reason_code not in ( 50, 51 )
                and trunc(b.effective_date) <= p_start_date
                and ( b.effective_end_date is null
                      or b.effective_end_date >= p_end_date )
                and a.rate_plan_id = d.rate_plan_id
                and ( ( p_invoice_freq = 'MONTHLY'
                        and b.one_time_flag = 'N' )     -- Added by Joshi 11293.
                      or ( p_invoice_freq <> 'MONTHLY'
                           and b.one_time_flag = 'Y' ) )
                and a.status = 'DRAFT'
                and a.entity_type = 'EMPLOYER'
                and a.rate_plan_id = b.rate_plan_id
                and c.status = 'A'
                and d.status = 'A'
                and b.invoice_param_id = d.invoice_param_id
                and d.invoice_type = 'FEE'
                and b.rate_code = to_char(c.reason_code)
        ) loop
            l_quantity := 0;
                 --l_invoice_days    := 0;
            l_line_type := null;
            l_pers_tbl := number_table();
            l_total_inv_amount := 0;
            l_no_of_months := 0;
            l_at_pers_tbl := number_table();
            l_a_quantity := 0;
            l_a_line_type := null;
            l_a_total_inv_amount := 0;
            l_a_no_of_months := 0;
            l_t_quantity := 0;
            l_t_line_type := null;
            l_t_total_inv_amount := 0;
            l_t_no_of_months := 0;

                -- Setup/Renewal fees are entered as Flat Fee
            if x.rate_basis = 'FLAT_FEE' then
                l_line_type := 'FLAT_FEE';
                l_quantity := 1;
                l_no_of_months := 1;
                l_total_inv_amount := x.rate_plan_cost;
                update rate_plan_detail
                set
                    effective_end_date =
                        case
                            when p_invoice_freq in ( 'SETUP', 'RENEWAL' ) then
                                p_start_date
                            else
                                p_end_date
                        end,
                    last_update_date = sysdate
                where
                        rate_code = x.rate_code
                    and one_time_flag = 'Y'
                    and effective_date <= p_start_date
                    and ( effective_end_date is null
                          or effective_end_date >= p_end_date )
                    and rate_plan_id = x.rate_plan_id;

                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'Processed Flat Fee' || l_no_of_months);

                       -- Added by Joshi for populating charged_to
                update ar_invoice
                set
                    charged_to = x.charged_to
                where
                    invoice_id = x.invoice_id;

                 -- Collect the charge from setup and get the data from aggregate and build the invoice lines
                 -- Active, Runout and Card charge lines are insreted here
            elsif x.rate_basis in ( 'ACTIVE', 'RUNOUT', 'CARD' ) then
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'Processing '
                                                                       || x.rate_basis
                                                                       || ' '
                                                                       || x.rate_code);

                for xx in (
                    select
                        count(start_date) * x.rate_plan_cost inv_cost,
                        pers_id,
                        count(start_date)                    quantity
                    from
                        invoice_distribution_summary ids
                    where
                            ids.invoice_id = x.invoice_id
                        and ids.invoice_kind = x.rate_basis
                        and ids.rate_code = x.rate_code
                                 --  and    ids.invoice_reason = 'INVOICE_LINE'
                    group by
                        pers_id
                    order by
                        3
                ) loop
                    pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice',
                                     'pers_id '
                                     || xx.pers_id
                                     || ' '
                                     || xx.quantity
                                     || ' no of months '
                                     || round(months_between(x.end_date, x.start_date)));

                    if
                        x.rate_code in ( '41', '31', '32', '33', '34',
                                         '35', '36', '37', '38', '39',
                                         '40', '42', '17' )
                        and x.rate_basis = 'ACTIVE'
                    then
                        if x.no_of_months > xx.quantity then
                            for kk in (
                                select
                                    termination_date
                                from
                                    ar_invoice_dist_plans
                                where
                                        pers_id = xx.pers_id
                                    and invoice_id = x.invoice_id
                                    and invoice_kind = x.rate_basis
                                group by
                                    pers_id,
                                    termination_date
                            ) loop
                                if kk.termination_date is not null then
                                    l_t_line_type := 'TERMINATION';
                                    l_t_quantity := l_t_quantity + 1;
                                    l_t_no_of_months := l_t_no_of_months + xx.quantity;
                                    l_t_total_inv_amount := l_t_total_inv_amount + nvl(xx.inv_cost, 0);
                                else
                                    l_a_line_type := 'NEW_ENROLLMENT';
                                    l_a_quantity := l_a_quantity + 1;
                                    l_a_no_of_months := l_a_no_of_months + xx.quantity;
                                    l_a_total_inv_amount := l_a_total_inv_amount + nvl(xx.inv_cost, 0);
                                end if;
                            end loop;

                            l_at_pers_tbl.extend;
                            l_at_pers_tbl(l_at_pers_tbl.count) := xx.pers_id;
                        else
                            l_line_type := x.rate_basis; -- xx.line_type ;
                            l_quantity := l_quantity + 1;
                            l_no_of_months := l_no_of_months + xx.quantity;
                            l_total_inv_amount := l_total_inv_amount + nvl(xx.inv_cost, 0);
                        end if;

                    else
                        l_line_type := x.rate_basis; -- xx.line_type ;
                        l_quantity := l_quantity + 1;
                        l_no_of_months := l_no_of_months + xx.quantity;
                        l_total_inv_amount := l_total_inv_amount + nvl(xx.inv_cost, 0);
                    end if;

                    l_pers_tbl.extend;
                    l_pers_tbl(l_pers_tbl.count) := xx.pers_id;
                end loop;

                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'Processed Active Plans');
            end if; -- rate_basis =cards

                --   IF l_quantity  <> 0 then  commented by Joshi for 11119. (exclude discount reason codes). added below
            if
                l_quantity <> 0
                and x.rate_code not in ( 264, 265, 266, 267 )
            then
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_line_type '
                                                                       || l_line_type
                                                                       || ' x.invoice_id :='
                                                                       || x.invoice_id
                                                                       || 'x.rate_code :='
                                                                       || x.rate_code
                                                                       || 'x.rate_description :='
                                                                       || x.rate_description
                                                                       || 'X.rate_plan_cost :='
                                                                       || x.rate_plan_cost
                                                                       || ' P_BATCH_NUMBER :='
                                                                       || p_batch_number);

                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_quantity ' || l_quantity);
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_no_of_months ' || l_no_of_months);
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_total_inv_amount ' || l_total_inv_amount);
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => l_line_type,
                    p_rate_code         => x.rate_code,
                    p_description       => x.rate_description,
                    p_quantity          => l_quantity,
                    p_no_of_months      => l_no_of_months,
                    p_rate_cost         => x.rate_plan_cost,
                    p_total_cost        => l_total_inv_amount,
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );

                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_invoice_line_id ' || l_invoice_line_id);
                for z in 1..l_pers_tbl.count loop
                    update invoice_distribution_summary
                    set
                        invoice_line_id = l_invoice_line_id
                    where
                            rate_code = x.rate_code
                        and invoice_id = x.invoice_id
                        and invoice_kind like '%'
                        || l_line_type
                        || '%'
                           and pers_id = l_pers_tbl(z);

                end loop;

            end if;

                 -- Added by Joshi for 11119 . insert discount reason in invoice lines
            if
                l_quantity <> 0
                and x.rate_code in ( 264, 265, 266, 267 )
            then
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'x.rate_code ' || x.rate_code);
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', ' X.rate_plan_cost ' || x.rate_plan_cost);
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_total_inv_amount ' || l_total_inv_amount);
                  --     pc_log.log_error('PC_INVOICE.process_pop_erisa_5500_inv','l_invoice_line_id '||l_invoice_line_id);

                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => l_line_type,
                    p_rate_code         => x.rate_code,
                    p_description       => nvl(x.description, x.rate_description), -- Added by Joshi for 12664
                    p_quantity          => l_quantity,
                    p_no_of_months      => l_no_of_months,
                    p_rate_cost         =>(x.rate_plan_cost * - 1),
                    p_total_cost        => null,
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );

                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_invoice_line_id ' || l_invoice_line_id);
            end if;
                    -- code end by Joshi for 11119 . insert discount reason in invoice lines

            if l_a_quantity <> 0 then
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_a_quantity ' || l_a_quantity);
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => l_a_line_type,
                    p_rate_code         => x.rate_code,
                    p_description       => x.rate_description,
                    p_quantity          => l_a_quantity,
                    p_no_of_months      => l_a_no_of_months,
                    p_rate_cost         => x.rate_plan_cost,
                    p_total_cost        => l_a_total_inv_amount,
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );

                for z in 1..l_at_pers_tbl.count loop
                    update invoice_distribution_summary
                    set
                        invoice_line_id = l_invoice_line_id,
                        invoice_reason = (
                            select distinct
                                decode(termination_date, null, 'NEW_ENROLLMENT', 'TERMINATION')
                            from
                                ar_invoice_dist_plans
                            where
                                    pers_id = l_at_pers_tbl(z)
                                and invoice_id = x.invoice_id
                                and invoice_kind = 'ACTIVE'
                        )
                    where
                            rate_code = x.rate_code
                        and invoice_id = x.invoice_id
                        and invoice_kind = 'ACTIVE'
                        and pers_id = l_at_pers_tbl(z);

                end loop;

            end if;

            if l_t_quantity <> 0 then
                pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice', 'l_t_quantity ' || l_t_quantity);
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => l_t_line_type,
                    p_rate_code         => x.rate_code,
                    p_description       => x.rate_description,
                    p_quantity          => l_t_quantity,
                    p_no_of_months      => l_t_no_of_months,
                    p_rate_cost         => x.rate_plan_cost,
                    p_total_cost        => l_t_total_inv_amount,
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );

                for z in 1..l_at_pers_tbl.count loop
                    update invoice_distribution_summary
                    set
                        invoice_line_id = l_invoice_line_id,
                        invoice_reason = (
                            select distinct
                                decode(termination_date, null, 'NEW_ENROLLMENT', 'TERMINATION')
                            from
                                ar_invoice_dist_plans
                            where
                                    pers_id = l_at_pers_tbl(z)
                                and invoice_id = x.invoice_id
                                and invoice_kind = 'ACTIVE'
                        )
                    where
                            rate_code = x.rate_code
                        and invoice_id = x.invoice_id
                        and invoice_kind = 'ACTIVE'
                        and pers_id = l_at_pers_tbl(z);

                end loop;

            end if;

        end loop; --rate_plan_detail/rate_code loop
                 -- Adjustment lines are insreted here

        l_quantity := 0;
        for x in (
            select
                a.invoice_id,
                b.rate_code,
                c.reason_name      rate_description,
                b.rate_plan_cost,
                count(ids.pers_id) quantity
            from
                ar_invoice                   a,
                rate_plan_detail             b,
                pay_reason                   c,
                invoice_distribution_summary ids
            where
                    a.batch_number = p_batch_number
                and trunc(b.effective_date) <= p_end_date
                and ( b.effective_end_date is null
                      or b.effective_end_date >= p_end_date )
                and a.status = 'DRAFT'
                and a.entity_type = 'EMPLOYER'
                and a.rate_plan_id = b.rate_plan_id
                and b.rate_basis = 'ACTIVE'
                and ids.invoice_id = a.invoice_id
                and exists (
                    select
                        *
                    from
                        invoice_parameters d
                    where
                            b.invoice_param_id = d.invoice_param_id
                        and a.rate_plan_id = d.rate_plan_id
                        and d.invoice_type = 'FEE'
                        and d.status = 'A'
                )
                and ids.invoice_kind = 'ADJUSTMENT'
                and ids.rate_code = b.rate_code
                and b.rate_code = to_char(c.reason_code)
            group by
                a.invoice_id,
                b.rate_code,
                c.reason_name,
                b.rate_plan_cost
        ) loop
            if x.quantity <> 0 then
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => 'ADJUSTMENT',
                    p_rate_code         => x.rate_code,
                    p_description       => x.rate_description,
                    p_quantity          => x.quantity,
                    p_no_of_months      => 1,
                    p_rate_cost         => x.rate_plan_cost,
                    p_total_cost        =>(- 1 * x.quantity * x.rate_plan_cost),
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );

                update invoice_distribution_summary
                set
                    invoice_line_id = l_invoice_line_id
                where
                        rate_code = x.rate_code
                    and invoice_id = x.invoice_id
                    and invoice_kind = 'ADJUSTMENT';

            end if;
        end loop;

              -- Active Adjustment

        for x in (
            select
                a.invoice_id,
                b.rate_code,
                c.reason_name      rate_description,
                b.rate_plan_cost,
                count(ids.pers_id) quantity,
                ids.invoice_days   invoice_days
            from
                ar_invoice                   a,
                rate_plan_detail             b,
                pay_reason                   c,
                invoice_distribution_summary ids
            where
                    a.batch_number = p_batch_number
                and trunc(b.effective_date) <= p_end_date
                and ( b.effective_end_date is null
                      or b.effective_end_date >= p_end_date )
                and a.status = 'DRAFT'
                and a.entity_type = 'EMPLOYER'
                and a.rate_plan_id = b.rate_plan_id
                and b.rate_basis = 'ACTIVE'
                and ids.invoice_id = a.invoice_id
                and ids.invoice_kind = 'ACTIVE_ADJUSTMENT'
                and exists (
                    select
                        *
                    from
                        invoice_parameters d
                    where
                            b.invoice_param_id = d.invoice_param_id
                        and d.invoice_type = 'FEE'
                        and d.status = 'A'
                        and a.rate_plan_id = d.rate_plan_id
                )
                and ids.rate_code = b.rate_code
                and b.rate_code = to_char(c.reason_code)
            group by
                a.invoice_id,
                b.rate_code,
                c.reason_name,
                b.rate_plan_cost,
                ids.invoice_days
        ) loop
            if x.quantity <> 0 then
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => 'ACTIVE_ADJUSTMENT',
                    p_rate_code         => x.rate_code,
                    p_description       => x.rate_description,
                    p_quantity          => x.quantity,
                    p_no_of_months      => x.invoice_days,
                    p_rate_cost         => x.rate_plan_cost,
                    p_total_cost        =>(x.quantity * x.invoice_days * x.rate_plan_cost),
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );

                update invoice_distribution_summary
                set
                    invoice_line_id = l_invoice_line_id
                where
                        rate_code = x.rate_code
                    and invoice_id = x.invoice_id
                    and invoice_kind = 'ACTIVE_ADJUSTMENT'
                    and invoice_days = x.invoice_days;

            end if;
        end loop;
             -- Applying Minimum Fees
        for x in (
            select
                batch_number,
                invoice_id,
                plan_type
            from
                ar_invoice
            where
                    batch_number = p_batch_number
                and invoice_reason = 'FEE'
                and status in ( 'GENERATED', 'DRAFT' )
        ) loop
            apply_service_charge(x.batch_number);
            apply_minimum_fee(x.invoice_id);
        end loop;

        apply_tax(p_batch_number);

              -- Processing Adjustments
              -- When we have excess credit left with us , we post it as payment
              -- then if there is anything left over we insert into setup and use it for following months
        for x in (
            select
                a.invoice_id,
                b.rate_code,
                b.rate_plan_cost,
                c.plan_type,
                c.reason_name              rate_description,
                a.start_date,
                a.end_date,
                b.rate_plan_id,
                sum(arl.total_line_amount) invoice_amount
            from
                ar_invoice       a,
                rate_plan_detail b,
                pay_reason       c,
                ar_invoice_lines arl
            where
                    a.batch_number = p_batch_number
                and c.reason_code in ( 50, 51 )
                and trunc(b.effective_date) <= a.start_date
                and ( b.effective_end_date is null
                      or b.effective_end_date >= a.end_date )
                and a.entity_type = 'EMPLOYER'
                and a.rate_plan_id = b.rate_plan_id
                and c.status = 'A'
                and exists (
                    select
                        *
                    from
                        invoice_parameters d
                    where
                            b.invoice_param_id = d.invoice_param_id
                        and a.rate_plan_id = d.rate_plan_id
                        and d.invoice_type = 'FEE'
                        and d.status = 'A'
                )
                and a.invoice_id = arl.invoice_id
                and b.rate_code = to_char(c.reason_code)
            group by
                a.invoice_id,
                b.rate_code,
                b.rate_plan_cost,
                c.plan_type,
                c.reason_name,
                b.rate_plan_id,
                a.start_date,
                a.end_date
        ) loop
            if x.rate_plan_cost > 0 then
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => 'FLAT_FEE',
                    p_rate_code         => x.rate_code,
                    p_description       => x.rate_description,
                    p_quantity          => 1,
                    p_no_of_months      => 1,
                    p_rate_cost         => x.rate_plan_cost,
                    p_total_cost        => x.rate_plan_cost,
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );
            end if;

                 -- Payment Posting of any credits left
            if x.rate_plan_cost < 0 then
                pc_invoice.post_invoices(
                    p_invoice_id     => x.invoice_id,
                    p_check_number   => x.plan_type
                                      || 'ADJ'
                                      || x.invoice_id,
                    p_check_amount   => least(x.invoice_amount,
                                            abs(x.rate_plan_cost)),
                    p_payment_method => 9,
                    p_check_date     => sysdate,
                    p_user_id        => 0,
                    p_paid_by        => 'NONE'
                ); -- added by Joshi for 8692	);

                update rate_plan_detail
                set
                    effective_end_date = x.end_date,
                    last_update_date = sysdate
                where
                        rate_code = x.rate_code
                    and one_time_flag = 'Y'
                    and effective_date <= x.start_date
                    and ( effective_end_date is null
                          or effective_end_date >= x.end_date )
                    and rate_plan_id = x.rate_plan_id;

                if abs(x.rate_plan_cost) - x.invoice_amount > 0 then
                    insert into rate_plan_detail (
                        rate_plan_detail_id,
                        rate_plan_id,
                        coverage_type,
                        calculation_type,
                        minimum_range,
                        maximum_range,
                        description,
                        rate_code,
                        rate_plan_cost,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        rate_basis,
                        effective_date,
                        one_time_flag
                    )
                        select
                            rate_plan_detail_seq.nextval,
                            rate_plan_id,
                            coverage_type,
                            calculation_type,
                            minimum_range,
                            maximum_range,
                            'Applying excess credit to next month',
                            rate_code,
                            x.invoice_amount + x.rate_plan_cost,
                            sysdate,
                            0,
                            sysdate,
                            0,
                            rate_basis,
                            trunc(sysdate, 'MM'),
                            one_time_flag
                        from
                            rate_plan_detail
                        where
                                rate_code = x.rate_code
                            and rate_plan_id = x.rate_plan_id
                            and effective_date >= x.start_date
                            and exists (
                                select
                                    *
                                from
                                    invoice_parameters d
                                where
                                        rate_plan_detail.invoice_param_id = d.invoice_param_id
                                    and d.invoice_type = 'FEE'
                                    and d.status = 'A'
                                    and rate_plan_detail.rate_plan_id = d.rate_plan_id
                            )
                            and ( effective_end_date is null
                                  or effective_end_date <= x.end_date );

                    dbms_output.put_line(' X.RATE_CODE ' || x.rate_code);
                    dbms_output.put_line('  X.RATE_PLAN_ID ' || x.rate_plan_id);
                    dbms_output.put_line('  X.RATE_PLAN_COST ' || abs(x.rate_plan_cost));
                    dbms_output.put_line('   X.INVOICE_AMOUNT ' || x.invoice_amount);
                end if;

            end if;

        end loop;

        for x in (
            select
                ar.invoice_id,
                ar.entity_id,
                ar.billing_date,
                sum(arl.total_line_amount) invoice_amount,
                ar.rate_plan_id
            from
                ar_invoice       ar,
                ar_invoice_lines arl
            where
                    ar.batch_number = p_batch_number
                and ar.invoice_id = arl.invoice_id
                and ar.status in ( 'GENERATED', 'DRAFT' )
                and arl.status in ( 'GENERATED', 'DRAFT' )
            group by
                ar.invoice_id,
                ar.entity_id,
                ar.billing_date,
                ar.rate_plan_id
        ) loop
            update ar_invoice
            set
                status =
                    case
                        when x.invoice_amount = 0 then
                            'POSTED'
                        else
                            'GENERATED'
                    end,
                invoice_amount = x.invoice_amount,
                pending_amount = x.invoice_amount - paid_amount,
                last_update_date = sysdate,
                last_updated_by = 0,
                plan_type = nvl(plan_type,
                                decode(
                                                pc_benefit_plans.get_entrp_ben_account_type(entity_id),
                                                'HRA',
                                                'HRA',
                                                'Stacked',
                                                'HRAFSA',
                                                'FSA'
                                            ))
            where
                invoice_id = x.invoice_id;

            update ar_invoice_lines
            set
                status = 'GENERATED',
                last_update_date = sysdate,
                last_updated_by = 0
            where
                invoice_id = x.invoice_id;
                            -- set last invoiced date
            update invoice_parameters
            set
                last_invoiced_date = x.billing_date
            where
                    entity_id = x.entity_id
                and entity_type = 'EMPLOYER'
                and invoice_type = 'FEE'
                and rate_plan_id = x.rate_plan_id;

        end loop;

   --     END IF;

       --  commit;
        x_error_status := 'S';
    exception
        when invoice_exception then
            pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice',
                             'Error message INVOICE_EXCEPTION '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise_application_error('-20001', l_error_message);
            rollback;
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('PC_INVOICE.process_hra_fsa_invoice',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            rollback;
    end process_hra_fsa_invoice;
  -- Just inserting the invoice line
    procedure insert_invoice_line (
        p_invoice_id          in number,
        p_invoice_line_type   in varchar2 default 'INVOICE_LINE',
        p_rate_code           in varchar2,
        p_description         in varchar2,
        p_quantity            in number,
        p_no_of_months        in number,
        p_rate_cost           in number,
        p_total_cost          in number default null,
        p_batch_number        in number,
        x_invoice_line_id     out number,
        p_rate_plan_detail_id in number default null
    ) is
    begin
        pc_log.log_error('PC_INVOICE.INSERT_INVOICE_LINE', 'P_INVOICE_ID ' || p_invoice_id);
        insert into ar_invoice_lines (
            invoice_line_id,
            invoice_id,
            invoice_line_type,
            rate_code,
            quantity,
            unit_rate_cost,
            total_line_amount,
            no_of_months,
            status,
            batch_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            description,
            rate_plan_detail_id
        ) values ( ar_invoice_lines_seq.nextval,
                   p_invoice_id,
                   p_invoice_line_type,
                   p_rate_code,
                   round(p_quantity, 2),
                   p_rate_cost,
                   round(
                       nvl(p_total_cost,
                           p_quantity * p_rate_cost * round(p_no_of_months, 2)),
                       2
                   ),
                   round(p_no_of_months, 2),
                   'DRAFT',
                   p_batch_number,
                   0,
                   sysdate,
                   0,
                   sysdate,
                   p_description,
                   p_rate_plan_detail_id ) returning invoice_line_id into x_invoice_line_id;

    exception
        when others then
            pc_log.log_error('PC_INVOICE.INSERT_INVOICE_LINE error ', 'others '
                                                                      || sqlerrm
                                                                      || dbms_utility.format_error_backtrace);
    end insert_invoice_line;
  -- Data Collection Procedures
  -- Acive Participants
    procedure proc_active_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
    begin
        pc_log.log_error('PC_INVOICE.proc_active_dist', 'Process Distribution for Invoice ID '
                                                        || p_invoice_id
                                                        || ' division code '
                                                        || g_division_code);
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_status,
            plan_code,
            plan_type,
            effective_date,
            termination_date,
            termination_req_date
            --,RENEWAL_DATE
            ,
            terminated,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            product_type,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                p.entrp_id,
                a.acc_id,
                a.pers_id,
                a.account_status,
                c.status,
                c.ben_plan_name --C.PLAN_CODE
                ,
                c.plan_type,
                c.effective_date,
                c.effective_end_date,
                c.termination_req_date
                --,  C.RENEWAL_DATE
                ,
                c.terminated,
                c.creation_date,
                'INVOICE' invoice_reason,
                1         invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'ACTIVE'  invoice_kind,
                p_start_date,
                p_end_date,
                c.product_type,
                p.division_code
            from
                account                   a,
                ben_plan_enrollment_setup c,
                person                    p
            where
                    p.entrp_id = p_entrp_id
                and p.pers_id = a.pers_id
                and a.acc_id = c.acc_id
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and p.division_code = g_division_code ) )
                and greatest(c.creation_date, c.effective_date) between c.plan_start_date and c.plan_end_date
                and c.status in ( 'A', 'I' )
                and c.plan_end_date >= p_end_date
                and ( c.effective_end_date is null
                      or c.effective_end_date between p_start_date and p_end_date
                      or ( c.effective_end_date > p_end_date
                           and c.effective_end_date <= c.plan_end_date ) )
      --      AND    NVL(c.effective_end_date,c.plan_start_date) < p_end_date
                and greatest(c.creation_date, c.effective_date) < nvl(c.effective_end_date, c.plan_end_date)  --effective date should be earlier than termination date
                and greatest(c.creation_date, c.effective_date) <= p_end_date
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = a.acc_id
                        and entrp_id = p.entrp_id
                        and invoice_id = p_invoice_id
                        and plan_type = c.plan_type
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and invoice_kind = 'ACTIVE'
                );

        pc_log.log_error('PC_INVOICE.proc_active_dist', 'No of rows processed for distribution plan ' || sql%rowcount);
    end proc_active_dist;

    procedure proc_hsa_active_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
        l_division_code varchar2(300);
        l_plan_code     number;
        l_account_type  varchar2(3);    -- Added by Swamy for Ticket#10104 on 21/09/2021
    begin
        pc_log.log_error('PC_INVOICE.proc_active_dist', 'Process Distribution for Invoice ID ' || p_invoice_id);
        l_account_type := pc_account.get_account_type_from_entrp_id(p_entrp_id);    -- Added by Swamy for Ticket#10104 on 21/09/2021

        for x in (
            select
                division_code
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
            l_division_code := x.division_code;
        end loop;

        if l_account_type = 'HSA' then      -- If cond. Added by Swamy for Ticket#10104 on 21/09/2021
            insert into ar_invoice_dist_plans (
                invoice_dist_plan_id,
                invoice_id,
                entrp_id,
                acc_id,
                pers_id,
                account_status,
                plan_code,
                effective_date,
                enrolled_date,
                invoice_reason,
                invoice_days,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                invoice_kind,
                division_code
            )
                select
                    ar_invoice_distribution_seq.nextval,
                    p_invoice_id,
                    p.entrp_id,
                    a.acc_id,
                    a.pers_id,
                    a.account_status,
                    a.plan_code,
                    a.start_date,
                    a.reg_date,
                    'INVOICE' invoice_reason,
                    1         invoice_days,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    'ACTIVE'  invoice_kind,
                    l_division_code
                from
                    account a,
                    person  p
                where
                        p.entrp_id = p_entrp_id
                    and p.pers_id = a.pers_id
                    and a.account_status in ( 1, 2, 3 ) /*Pending accounts should also be pulled.Ticket#7391 */
                    and ( ( l_division_code is null )
                          or ( l_division_code is not null
                               and p.division_code = l_division_code ) );/*Ticket#7391.HSA Invoicing */

        elsif l_account_type = 'LSA' then      -- Added by Swamy for Ticket#10104 on 21/09/2021

            insert into ar_invoice_dist_plans (
                invoice_dist_plan_id,
                invoice_id,
                entrp_id,
                acc_id,
                pers_id,
                account_status,
                plan_code,
                effective_date,
                enrolled_date,
                invoice_reason,
                invoice_days,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                invoice_kind,
                division_code
            )
                select
                    ar_invoice_distribution_seq.nextval,
                    p_invoice_id,
                    p.entrp_id,
                    a.acc_id,
                    a.pers_id,
                    a.account_status,
                    a.plan_code,
                    a.start_date,
                    a.reg_date,
                    'INVOICE' invoice_reason,
                    1         invoice_days,
                    sysdate,
                    0,
                    sysdate,
                    0,
                    'ACTIVE'  invoice_kind,
                    l_division_code
                from
                    account a,
                    person  p
                where
                        p.entrp_id = p_entrp_id
                    and p.pers_id = a.pers_id
                    and a.account_status in ( 1, 2, 3 ) /*Pending accounts should also be pulled.Ticket#7391 */
                    and ( ( l_division_code is null )
                          or ( l_division_code is not null
                               and p.division_code = l_division_code ) );
                 /*AND (pc_account.check_minimum_balance(a.acc_id, l_account_type,p_start_date ,p_end_date ) = 'Y'
                  OR pc_account.acc_balance( a.acc_id
                                            ,TO_DATE('01-JAN-2004','dd-mon-yyyy')   -- Changed by Swamy for Ticket#11453
                                            ,p_end_date
                                            ,l_account_type
                                            ,NULL
                                            ,NULL
                                            ,NULL) > 0 );*/  -- Commented by Swamy as per discussion on 03/03/2023, no need to check the Balance, only check for the account status.
        end if;

        pc_log.log_error('PC_INVOICE.proc_active_dist', 'No of rows processed for distribution plan ' || sql%rowcount);
    end proc_hsa_active_dist;

    procedure proc_hsa_distribution_summary (
        p_invoice_id in number,
        p_start_date in date,
        p_end_date   in date,
        p_plan_code  in number
    )/*Ticket 7391 Accept plan code as i/p Param */ is
        l_account_type account.account_type%type := 'HSA';   -- Added by Swamy for Ticket#9912 on 10/08/2021
    begin

    -- Added by Swamy for Ticket#9912 on 10/08/2021
        for j in (
            select
                account_type
            from
                account    a,
                ar_invoice c
            where
                    c.invoice_id = p_invoice_id
                and a.acc_id = c.acc_id
                and a.account_type = 'LSA'
        ) loop
            l_account_type := j.account_type;
        end loop;

        insert into invoice_distribution_summary (
            invoice_id,
            entrp_id,
            invoice_kind,
            invoice_reason,
            pers_id,
            plans,
            rate_code,
            account_type,
            invoice_days,
            start_date,
            end_date,
            rate_amount,
            division_code
        )
            select
                p_invoice_id,
                c.entity_id,
                'ACTIVE',
                'ACTIVE',
                a.pers_id,
                a.plan_code,
                2 ---Rate code will be 2 for monthly fees
                ,
                nvl(l_account_type, 'HSA')   -- 'HSA' replaced by l_account_type by Swamy for Ticket#9912 on 10/08/2021
                ,
                1,
                p_start_date,
                p_end_date
               --, b.rate_plan_cost /*Ticket#7391 */
                ,
                case
                 --WHEN Pc_Plan.fcustom_fee_value(a.entrp_id,2) <> 0 AND p_plan_code = a.plan_code THEN /*Custom setup for monthly fee */
                 --As per cleint requirement as long as custom fee is setup, it will be applicable for all ees irrespective of plan associated.
                    when pc_plan.fcustom_fee_value(a.entrp_id, 2) <> 0 then /*Custom setup for monthly fee */
                        pc_plan.fcustom_fee_value(a.entrp_id, 2)
                    else
                        pc_plan.fee_value(d.plan_code, 2)
                end fee,
                a.division_code
            from
                ar_invoice_dist_plans a,
                invoice_parameters    b,
                ar_invoice            c,
                account               d  /*Ticket#7391 */
            where
                    a.invoice_id = p_invoice_id
                and a.invoice_id = c.invoice_id
                and b.entity_id = a.entrp_id
                and b.payment_method = 'DIRECT_DEPOSIT'
                and b.invoice_type = 'FEE'
                and b.invoice_frequency = 'MONTHLY'
          -- AND    b.rate_plan_id = c.rate_plan_id
           --AND    b.rate_code = 2
                and a.acc_id = d.acc_id
                and a.plan_code = d.plan_code
                and trunc(a.effective_date) <= p_end_date;

    end proc_hsa_distribution_summary;
-- Data Aggregation Procedures
    procedure proc_distribution_summary (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
    begin
        insert into invoice_distribution_summary (
            invoice_id,
            entrp_id,
            invoice_kind,
            invoice_reason,
            pers_id,
            plans,
            rate_code,
            account_type,
            invoice_days,
            start_date,
            end_date
        )
            select
                p_invoice_id,
                p_entrp_id,
                case
                    when invoice_kind like 'RUNOUT%' then
                        'RUNOUT'
                    when invoice_kind = 'TERM_ADJUSTMENT' then
                        'ADJUSTMENT'
                    when invoice_kind = 'GRACE_ACTIVE'    then
                        'ACTIVE'
                    else
                        invoice_kind
                end,
                invoice_kind,
                x.pers_id,
                x.plan_type,
                b.reason_code,
                (
                    select
                        account_type
                    from
                        account
                    where
                        entrp_id = p_entrp_id
                ),
                decode(invoice_kind, 'ACTIVE_ADJUSTMENT', invoice_days, 1),
                p_start_date,
                p_end_date
            from
                (
                    select
                        pers_id -- HRA only
                        ,
                        'HRA' plan_type,
                        invoice_kind,
                        1     invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            invoice_id = p_invoice_id
                        and invoice_kind = 'ACTIVE'
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and ( termination_date is null
                              or termination_date between p_start_date and p_end_date
                              or termination_date > p_end_date )
                        and product_type = 'HRA'
                    group by
                        pers_id,
                        invoice_kind,
                        x.termination_date
                    union all
                    (
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            invoice_kind,
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                            and invoice_kind = 'ACTIVE'
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and invoice_kind not like 'CARD%'
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                    and ( termination_date is null
                                          or termination_date between p_start_date and p_end_date )
                            )
                        group by
                            pers_id,
                            invoice_kind
                        union
                        select
                            pers_id -- FSA Combo, if there is any plan in runout but other plans are ACTIVE then they should be considered as ACTIVE
                            ,
                            'FSA_COMBO',
                            'ACTIVE',
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                            and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'RUNOUT_INVOICE_TERM' )
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and ( termed_date between p_start_date and p_end_date
                                  or termed_date > p_end_date )
                            and exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and invoice_kind = 'ACTIVE'
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                       'PKG', 'UA1', 'TP2' )
                            )
                            and (
                                select
                                    count(*)
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and invoice_kind = 'ACTIVE'
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                            ) = 1
                        group by
                            pers_id,
                            invoice_kind
                        union
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            invoice_kind,
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                            and invoice_kind = 'ACTIVE'
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and invoice_kind not like 'CARD%'
                                    and invoice_kind not in ( 'ACTIVE_ADJUSTMENT', 'ACTIVE' )
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                       'PKG', 'UA1', 'TP2' )
                                    and ( termination_date < p_start_date
                                          and termed_date >= p_end_date )
                            )
                        group by
                            pers_id,
                            invoice_kind
                        union
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            invoice_kind,
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind = 'ACTIVE'
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        group by
                            pers_id,
                            invoice_kind
                        having
                            count(distinct plan_type) > 1
                    )
                    union all
                    (
                        select
                            pers_id -- Transit  Combo
                            ,
                            'TRN_PKG',
                            invoice_kind,
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind = 'ACTIVE'
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and invoice_kind not like 'CARD%'
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                                    and ( termination_date is null
                                          or termination_date between p_start_date and p_end_date
                                          or termination_date > p_end_date )
                            )
                            and exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and invoice_kind not like 'CARD%'
                                    and a.invoice_id = x.invoice_id
                                    and invoice_kind <> 'ACTIVE'
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                    and ( termination_date < p_start_date
                                          and termed_date >= p_end_date )
                            )
                        group by
                            pers_id,
                            invoice_kind
                  --  HAVING COUNT(DISTINCT plan_type) > 1
                        union
                        select
                            pers_id -- Transit  Combo
                            ,
                            'TRN_PKG',
                            invoice_kind,
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind = 'ACTIVE'
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and invoice_kind not like 'CARD%'
                                    and invoice_kind <> 'ACTIVE'
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                    and ( termination_date < p_start_date
                                          and termed_date >= p_end_date )
                            )
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and invoice_kind not like 'CARD%'
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                                    and ( termination_date is null
                                          or termination_date between p_start_date and p_end_date
                                          or termination_date > p_end_date )
                            )
                        group by
                            pers_id,
                            invoice_kind
                        having
                            count(distinct plan_type) > 1
                    )
                    union all
                    select
                        pers_id -- Individual plans
                        ,
                        plan_type,
                        invoice_kind,
                        1 invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            (
                                select
                                    count(distinct plan_type)
                                from
                                    ar_invoice_dist_plans
                                where
                                        pers_id = x.pers_id
                                    and invoice_id = x.invoice_id
                                --  and   invoice_kind = x.invoice_kind
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                       'PKG', 'UA1', 'TP2' )
                            ) = 1
                        and invoice_id = p_invoice_id
                        and invoice_kind = 'ACTIVE'
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and ( termination_date is null
                              or termination_date between p_start_date and p_end_date
                              or termination_date > p_end_date )
                        and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                           'PKG', 'UA1', 'TP2' )
                    union all
                    select
                        pers_id -- HRA only
                        ,
                        'HRA' plan_type,
                        decode(invoice_kind, 'GRACE_ACTIVE', 'ACTIVE', invoice_kind),
                        1     invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            invoice_id = p_invoice_id
                        and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'RUNOUT_INVOICE_TERM', 'GRACE_ACTIVE' )
                        and ( termination_date <= p_start_date
                              or termination_date between p_start_date and p_end_date ) -- added on 5/15 for bug
                        and termed_date >= p_end_date
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and product_type = 'HRA'
                        and not exists (
                            select
                                *
                            from
                                ar_invoice_dist_plans y
                            where
                                    y.pers_id = x.pers_id
                                and invoice_kind = 'ACTIVE'
                                and product_type = 'HRA'
                                and y.invoice_id = x.invoice_id
                        )
                    group by
                        pers_id,
                        invoice_kind,
                        x.termination_date
                    union all
                    (
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            decode(invoice_kind, 'GRACE_ACTIVE', 'ACTIVE', invoice_kind),
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                            and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'RUNOUT_INVOICE_TERM', 'GRACE_ACTIVE' )
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and ( termination_date <= p_start_date
                                  or termination_date between p_start_date and p_end_date ) -- added on 5/15 for bug
                            and termed_date >= p_end_date
                            and exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and termination_date < p_start_date
                                    and termed_date >= p_end_date
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and invoice_kind not like 'CARD%'
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                            )
                        group by
                            pers_id,
                            invoice_kind
                        union
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            decode(invoice_kind, 'GRACE_ACTIVE', 'ACTIVE', invoice_kind),
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'RUNOUT_INVOICE_TERM', 'GRACE_ACTIVE' )
                            and ( termination_date <= p_start_date
                                  or termination_date between p_start_date and p_end_date ) -- added on 5/15 for bug
                            and termed_date >= p_end_date
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        group by
                            pers_id,
                            invoice_kind
                        having
                            count(distinct plan_type) > 1
                        union
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            decode(invoice_kind, 'GRACE_ACTIVE', 'ACTIVE', invoice_kind),
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'RUNOUT_INVOICE_TERM', 'GRACE_ACTIVE' )
                            and ( termination_date <= p_start_date
                                  or termination_date between p_start_date and p_end_date ) -- added on 5/15 for bug
                            and termed_date >= p_end_date
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and invoice_kind not like 'CARD%'
                                    and invoice_id = x.invoice_id
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                       'PKG', 'UA1', 'TP2' )
                                    and invoice_kind = 'ACTIVE'
                            )
                        group by
                            pers_id,
                            invoice_kind
                        having
                            count(distinct plan_type) > 1
                    )
                    union all
                    (
                        select
                            pers_id -- FSA Combo
                            ,
                            'TRN_PKG',
                            decode(invoice_kind, 'GRACE_ACTIVE', 'ACTIVE', invoice_kind),
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'RUNOUT_INVOICE_TERM', 'GRACE_ACTIVE' )
                            and ( termination_date <= p_start_date
                                  or termination_date between p_start_date and p_end_date ) -- added on 5/15 for bug
                            and termed_date >= p_end_date
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and invoice_kind not like 'CARD%'
                                    and a.invoice_id = x.invoice_id
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                            )
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and invoice_kind not like 'CARD%'
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                    and invoice_kind = 'ACTIVE'
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and invoice_id = x.invoice_id
                            )
                        group by
                            pers_id,
                            invoice_kind
                        having
                            count(distinct plan_type) > 1
                    )
                    union all
                    select
                        pers_id -- Individual plans
                        ,
                        plan_type,
                        decode(invoice_kind, 'GRACE_ACTIVE', 'ACTIVE', invoice_kind),
                        1 invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            (
                                select
                                    count(distinct plan_type)
                                from
                                    ar_invoice_dist_plans
                                where
                                        pers_id = x.pers_id
                                    and invoice_id = x.invoice_id
                              --    and   invoice_kind = x.invoice_kind
                              --     AND    termination_date < p_start_date
                              --    AND    termed_date >= p_end_date
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                       'PKG', 'UA1', 'TP2' )
                            ) = 1
                        and invoice_id = p_invoice_id
                        and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'RUNOUT_INVOICE_TERM', 'GRACE_ACTIVE' )
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and ( termination_date <= p_start_date
                              or termination_date between p_start_date and p_end_date ) -- added on 5/15 for bug
                        and termed_date >= p_end_date
                        and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                           'PKG', 'UA1', 'TP2' )
                    union all
                    select
                        pers_id -- HRA only
                        ,
                        'HRA' plan_type,
                        'TERM_ADJUSTMENT',
                        1     invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            invoice_id = p_invoice_id
                        and invoice_kind = 'TERM_ADJUSTMENT'
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and termination_date < p_start_date
                        and termination_req_date between p_start_date and p_end_date
                        and product_type = 'HRA'
                    group by
                        pers_id,
                        invoice_kind,
                        x.termination_date
                    union all
                    (
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            'TERM_ADJUSTMENT',
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                            and invoice_kind = 'TERM_ADJUSTMENT'
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and termination_date < p_start_date
                            and termination_req_date between p_start_date and p_end_date
                            and exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and termination_date < p_start_date
                                    and termed_date >= p_end_date
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and invoice_kind not like 'CARD%'
                                    and invoice_id = x.invoice_id
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                            )
                        group by
                            pers_id,
                            invoice_kind
                        union
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            'TERM_ADJUSTMENT',
                            1 invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind = 'TERM_ADJUSTMENT'
                            and termination_date < p_start_date
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and termination_req_date between p_start_date and p_end_date
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        group by
                            pers_id,
                            invoice_kind
                        having
                            count(distinct plan_type) > 1
                    )
                    union all
                    select
                        pers_id -- Transit  Combo
                        ,
                        'TRN_PKG',
                        'TERM_ADJUSTMENT',
                        1 invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            invoice_id = p_invoice_id
                        and invoice_kind = 'TERM_ADJUSTMENT'
                        and termination_date < p_start_date
                        and termination_req_date between p_start_date and p_end_date
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                        and not exists (
                            select
                                *
                            from
                                ar_invoice_dist_plans a
                            where
                                    a.pers_id = x.pers_id
                                and invoice_id = x.invoice_id
                                and start_date = p_start_date
                                and end_date = p_end_date
                                and invoice_kind not like 'CARD%'
                                and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        )
                    group by
                        pers_id,
                        invoice_kind
                    having
                        count(distinct plan_type) > 1
                    union all
                    select
                        pers_id -- Individual plans
                        ,
                        plan_type,
                        'TERM_ADJUSTMENT',
                        1 invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            (
                                select
                                    count(distinct plan_type)
                                from
                                    ar_invoice_dist_plans
                                where
                                        pers_id = x.pers_id
                                    and invoice_id = x.invoice_id
                                    and invoice_kind = x.invoice_kind
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and termination_date < p_start_date
                                    and termination_req_date between p_start_date and p_end_date
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                       'PKG', 'UA1', 'TP2' )
                            ) = 1
                        and invoice_id = p_invoice_id
                        and invoice_kind = 'TERM_ADJUSTMENT'
                        and termination_date <= p_start_date
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and termination_req_date between p_start_date and p_end_date
                        and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                           'PKG', 'UA1', 'TP2' )
                    union all
                    select
                        pers_id -- HRA only
                        ,
                        'HRA'                                                     plan_type,
                        invoice_kind,
                        round((trunc(enrolled_date, 'MM') - effective_date) / 30) invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            invoice_id = p_invoice_id
                        and invoice_kind = 'ACTIVE_ADJUSTMENT'
                        and ( termination_date is null
                              or termination_date between p_start_date and p_end_date
                              or termination_date > p_end_date )
                        and enrolled_date between p_start_date and p_end_date
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and effective_date < p_start_date
                        and product_type = 'HRA' --Vanitha:08/05/2020: not sure who had this product type here this is incorrect 'TP2'
                    group by
                        pers_id,
                        invoice_kind,
                        x.termination_date,
                        round((trunc(enrolled_date, 'MM') - effective_date) / 30)
                    union all
                    (
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            invoice_kind,
                            round((trunc(enrolled_date, 'MM') - effective_date) / 30) invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                            and invoice_kind = 'ACTIVE_ADJUSTMENT'
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and enrolled_date between p_start_date and p_end_date
                            and effective_date < p_start_date
                            and exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and a.invoice_id = x.invoice_id
                                    and invoice_kind not like 'CARD%'
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                    and ( termination_date is null
                                          or termination_date between p_start_date and p_end_date )
                            )
                        group by
                            pers_id,
                            invoice_kind,
                            round((trunc(enrolled_date, 'MM') - effective_date) / 30)
                        union
                        select
                            pers_id -- FSA Combo
                            ,
                            'FSA_COMBO',
                            invoice_kind,
                            round((trunc(enrolled_date, 'MM') - effective_date) / 30) invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind = 'ACTIVE_ADJUSTMENT'
                            and enrolled_date between p_start_date and p_end_date
                            and effective_date < p_start_date
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                        group by
                            pers_id,
                            invoice_kind,
                            round((trunc(enrolled_date, 'MM') - effective_date) / 30)
                        having
                            count(distinct plan_type) > 1
                    )
                    union all
                    (
                        select
                            pers_id -- Transit  Combo
                            ,
                            'TRN_PKG',
                            invoice_kind,
                            round((trunc(enrolled_date, 'MM') - effective_date) / 30) invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind = 'ACTIVE_ADJUSTMENT'
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and enrolled_date between p_start_date and p_end_date
                            and effective_date < p_start_date
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and invoice_kind not like 'CARD%'
                                    and a.invoice_id = x.invoice_id
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                                    and ( termination_date is null
                                          or termination_date between p_start_date and p_end_date
                                          or termination_date > p_end_date )
                            )
                            and exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and invoice_kind not like 'CARD%'
                                    and invoice_kind <> 'ACTIVE'
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                    and a.invoice_id = x.invoice_id
                                    and ( termination_date < p_start_date
                                          and termed_date >= p_end_date )
                            )
                        group by
                            pers_id,
                            invoice_kind,
                            round((trunc(enrolled_date, 'MM') - effective_date) / 30)
                  --  HAVING COUNT(DISTINCT plan_type) > 1
                        union
                        select
                            pers_id -- Transit  Combo
                            ,
                            'TRN_PKG',
                            invoice_kind,
                            round((trunc(enrolled_date, 'MM') - effective_date) / 30) invoice_days
                        from
                            ar_invoice_dist_plans x
                        where
                                invoice_id = p_invoice_id
                            and invoice_kind = 'ACTIVE_ADJUSTMENT'
                            and enrolled_date between p_start_date and p_end_date
                            and start_date = p_start_date
                            and end_date = p_end_date
                            and effective_date < p_start_date
                            and ( termination_date is null
                                  or termination_date between p_start_date and p_end_date
                                  or termination_date > p_end_date )
                            and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and invoice_kind not like 'CARD%'
                                    and invoice_kind <> 'ACTIVE'
                                    and a.invoice_id = x.invoice_id
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'TRN', 'PKG', 'UA1', 'TP2' )
                                    and ( termination_date < p_start_date
                                          and termed_date >= p_end_date )
                            )
                            and not exists (
                                select
                                    *
                                from
                                    ar_invoice_dist_plans a
                                where
                                        a.pers_id = x.pers_id
                                    and invoice_kind not like 'CARD%'
                                    and a.invoice_id = x.invoice_id
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF' )
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and ( termination_date is null
                                          or termination_date between p_start_date and p_end_date
                                          or termination_date > p_end_date )
                            )
                        group by
                            pers_id,
                            invoice_kind,
                            round((trunc(enrolled_date, 'MM') - effective_date) / 30)
                        having
                            count(distinct plan_type) > 1
                    )
                    union all
                    select
                        pers_id -- Individual plans
                        ,
                        plan_type,
                        invoice_kind,
                        round((trunc(enrolled_date, 'MM') - effective_date) / 30) invoice_days
                    from
                        ar_invoice_dist_plans x
                    where
                            (
                                select
                                    count(distinct plan_type)
                                from
                                    ar_invoice_dist_plans
                                where
                                        pers_id = x.pers_id
                                    and invoice_id = x.invoice_id
                                --  and   invoice_kind = x.invoice_kind
                                    and start_date = p_start_date
                                    and end_date = p_end_date
                                    and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                                       'PKG', 'UA1', 'TP2' )
                            ) = 1
                        and invoice_id = p_invoice_id
                        and invoice_kind = 'ACTIVE_ADJUSTMENT'
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and enrolled_date between p_start_date and p_end_date
                        and effective_date < p_start_date
                        and ( termination_date is null
                              or termination_date between p_start_date and p_end_date
                              or termination_date > p_end_date )
                        and plan_type in ( 'FSA', 'DCA', 'IIR', 'LPF', 'TRN',
                                           'PKG', 'UA1', 'TP2' )
                )          x,
                pay_reason b
            where
                b.reason_code not in ( 50, 49, 180, 48, 47,
                                       46, 45, 44, 43, 42,
                                       41, 51 )
                and x.plan_type = b.plan_type;
  -- Card Charges
        insert into invoice_distribution_summary (
            invoice_id,
            entrp_id,
            invoice_kind,
            invoice_reason,
            pers_id,
            plans,
            rate_code,
            account_type,
            invoice_days,
            start_date,
            end_date
        )
            select
                p_invoice_id,
                p_entrp_id,
                'CARD',
                'DEBIT_CARD',
                a.pers_id,
                plan_type,
                case
                    when invoice_kind = 'CARD_ISSUANCE'           then
                        '16'
                    when invoice_kind = 'LOST_STOLEN_REPLACEMENT' then
                        '4'
                end,
                b.account_type,
                case
                    when invoice_kind = 'CARD_ISSUANCE'           then
                        a.invoice_days - 2
                    when invoice_kind = 'LOST_STOLEN_REPLACEMENT' then
                        a.invoice_days
                end,
                p_start_date,
                p_end_date
            from
                ar_invoice_dist_plans a,
                account               b
            where
                invoice_kind in ( 'CARD_ISSUANCE', 'LOST_STOLEN_REPLACEMENT' )
                and a.entrp_id = b.entrp_id
                and b.entrp_id = p_entrp_id
                and invoice_id = p_invoice_id
                and case
                    when invoice_kind = 'CARD_ISSUANCE'           then
                        a.invoice_days - 2
                    when invoice_kind = 'LOST_STOLEN_REPLACEMENT' then
                        a.invoice_days
                    end > 0
                and not exists (
                    select
                        *
                    from
                        invoice_distribution_summary x
                    where
                            a.pers_id = x.pers_id
                        and x.invoice_id = a.invoice_id
                        and rate_code in ( '16', '4' )
                );

        insert into invoice_distribution_summary (
            invoice_id,
            entrp_id,
            invoice_kind,
            invoice_reason,
            pers_id,
            plans,
            rate_code,
            account_type,
            invoice_days,
            start_date,
            end_date
        )
            select
                p_invoice_id,
                p_entrp_id,
                'CARD',
                'DEBIT_CARD',
                a.pers_id,
                plan_type,
                '17',
                b.account_type,
                round(months_between(p_end_date, p_start_date)),
                p_start_date,
                p_end_date
            from
                ar_invoice_dist_plans a,
                account               b
            where
                    invoice_kind = 'CARD_CHARGE'
                and a.pers_id = b.pers_id
                and a.entrp_id = p_entrp_id
                and invoice_id = p_invoice_id
                and nvl(termed_date, p_end_date) >= p_end_date;


  -- EOB Charges
        insert into invoice_distribution_summary (
            invoice_id,
            entrp_id,
            invoice_kind,
            invoice_reason,
            pers_id,
            plans,
            rate_code,
            account_type,
            invoice_days,
            start_date,
            end_date
        )
            select
                p_invoice_id,
                p_entrp_id,
                'ACTIVE',
                'EOB_CHARGE',
                a.pers_id,
                plan_type,
                '41',
                b.account_type,
                1,
                p_start_date,
                p_end_date
            from
                ar_invoice_dist_plans a,
                account               b,
                (
                    select
                        add_months(
                            trunc(p_start_date, 'MM'),
                            1 * level - 1
                        )  start_date,
                        last_day(add_months(
                            trunc(p_start_date, 'MM'),
                            1 * level - 1
                        )) end_date
                    from
                        dual
                    connect by
                        level <= months_between(p_end_date, p_start_date) + 1
                    order by
                        end_date
                )                     c
            where
                invoice_kind like 'EOB_CHARGE'
                and a.entrp_id = b.entrp_id
                and ( a.termination_req_date between c.start_date and c.end_date
                      or a.termination_req_date is null )
                and ( a.enrolled_date between c.start_date and c.end_date
                      or a.enrolled_date <= c.start_date )
                and b.entrp_id = p_entrp_id
                and invoice_id = p_invoice_id;
-- SFORD   Charges
        insert into invoice_distribution_summary (
            invoice_id,
            entrp_id,
            invoice_kind,
            invoice_reason,
            pers_id,
            plans,
            rate_code,
            account_type,
            invoice_days,
            start_date,
            end_date
        )
            select
                p_invoice_id,
                p_entrp_id,
                'ACTIVE',
                'SFORD_CHARGE',
                a.pers_id,
                plan_type,
                '42',
                b.account_type,
                1,
                p_start_date,
                p_end_date
            from
                ar_invoice_dist_plans a,
                account               b,
                (
                    select
                        add_months(
                            trunc(p_start_date, 'MM'),
                            1 * level - 1
                        )  start_date,
                        last_day(add_months(
                            trunc(p_start_date, 'MM'),
                            1 * level - 1
                        )) end_date
                    from
                        dual
                    connect by
                        level <= months_between(p_end_date, p_start_date) + 1
                    order by
                        end_date
                )                     c
            where
                invoice_kind like 'SFORD_CHARGE'
                and a.entrp_id = b.entrp_id
                and b.entrp_id = p_entrp_id
                and ( a.termed_date between c.start_date and c.end_date
                      or a.termed_date is null )
                and a.enrolled_date <= c.end_date
                and invoice_id = p_invoice_id;

    end proc_distribution_summary;

    procedure proc_runout_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is

        l_invoice_reason       varchar2(25);
        l_invoice_kind         varchar2(25);
        l_credit_given_cnt     number;
        l_un_termed_plan_cnt   number;
        l_invoice_type         varchar2(5);
        l_account_type         varchar2(5);
        l_app_exception exception;
        l_invoiced_but_termed  number;
        l_active_plan_cnt      number;
        l_term_adjusted_inv_id number;
        l_inv_rerun            varchar2(6);
    begin
        pc_log.log_error('PC_INVOICE.proc_runout_credit_dist', 'proc_runout_credit_dist begins');
    -- plan end dated/not renewed plans
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_status,
            plan_code,
            plan_type,
            effective_date,
            termination_date,
            termination_req_date,
            terminated,
            termed_date,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            product_type,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                d.entrp_id,
                c.acc_id,
                c.pers_id,
                c.account_status,
                p.status,
                p.ben_plan_name --C.PLAN_CODE
                ,
                p.plan_type,
                p.effective_date,
                p.plan_end_date,
                p.termination_req_date,
                decode(p.effective_end_date, null, 'N', 'Y'),
                last_day(p.plan_end_date + nvl(p.grace_period, 0) + nvl(p.runout_period_days, 0)),
                p.creation_date,
                'INVOICE' invoice_reason,
                1         invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                case
                    when p.plan_end_date + nvl(p.grace_period, 0) > p_end_date                        then
                        'GRACE_ACTIVE'
                    when p.plan_end_date + nvl(p.grace_period, 0) between p_start_date and p_end_date then
                        'GRACE_ACTIVE'
                    else
                        'RUNOUT_PLAN_YEAR'
                end       invoice_kind,
                p_start_date,
                p_end_date,
                p.product_type,
                d.division_code
            from
                ben_plan_enrollment_setup p,
                account                   c,
                person                    d
            where
                    p.acc_id = c.acc_id
                and c.pers_id = d.pers_id
                and d.entrp_id = p_entrp_id
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and d.division_code = g_division_code ) )
                and last_day(p.plan_end_date + nvl(p.grace_period, 0) + nvl(p.runout_period_days, 0)) >= p_end_date
                and p.plan_end_date <= p_start_date
                and p.effective_end_date is null
                and p.status in ( 'A', 'I' )
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = c.acc_id
                        and plan_type = p.plan_type
                        and ben_plan_enrollment_setup.status in ( 'A', 'I' )
                        and plan_start_date > p.plan_end_date
                        and plan_end_date > sysdate
                )
                and get_actual_balance(p.acc_id,
                                       p.plan_type,
                                       p.plan_start_date,
                                       last_day(p.plan_end_date + nvl(p.grace_period, 0) + nvl(p.runout_period_days, 0))) > 0
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = c.acc_id
                        and entrp_id = d.entrp_id
                        and invoice_id = p_invoice_id
                        and plan_type = p.plan_type
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'ACTIVE' )
                );

    end proc_runout_dist;

    procedure proc_term_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is

        l_invoice_reason       varchar2(25);
        l_invoice_kind         varchar2(25);
        l_credit_given_cnt     number;
        l_un_termed_plan_cnt   number;
        l_invoice_type         varchar2(5);
        l_account_type         varchar2(5);
        l_app_exception exception;
        l_invoiced_but_termed  number;
        l_active_plan_cnt      number;
        l_term_adjusted_inv_id number;
        l_inv_rerun            varchar2(6);
    begin
        pc_log.log_error('PC_INVOICE.proc_term_dist', 'proc_term_dist begins');
        pc_log.log_error('PC_INVOICE.proc_term_dist', 'p_entrp_id '
                                                      || p_entrp_id
                                                      || ' p_invoice_id '
                                                      || p_invoice_id);
        pc_log.log_error('PC_INVOICE.proc_term_dist', 'p_start_date '
                                                      || p_start_date
                                                      || ' p_end_date'
                                                      || p_end_date);

    -- plan end dated/not renewed plans
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_status,
            plan_code,
            plan_type,
            effective_date,
            termination_date,
            termination_req_date,
            terminated,
            termed_date,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            product_type,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                d.entrp_id,
                c.acc_id,
                c.pers_id,
                c.account_status,
                p.status,
                p.ben_plan_name --C.PLAN_CODE
                ,
                p.plan_type,
                p.effective_date,
                p.effective_end_date,
                p.termination_req_date,
                'Y',
                last_day(
                    case
                        when p.runout_period_term = 'CPE' then
                            p.effective_end_date + nvl(p.runout_period_days, 0)
                        else p.plan_end_date + nvl(p.runout_period_days, 0)
                    end
                ),
                p.creation_date,
                'INVOICE'             invoice_reason,
                1                     invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'RUNOUT_INVOICE_TERM' invoice_kind,
                p_start_date,
                p_end_date,
                p.product_type,
                d.division_code
            from
                ben_plan_enrollment_setup p,
                account                   c,
                person                    d
            where
                    p.acc_id = c.acc_id
                and c.pers_id = d.pers_id
                and d.entrp_id = p_entrp_id
                and p.status in ( 'A', 'I' )
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and d.division_code = g_division_code ) )
                and nvl(p.runout_period_days, 0) > 0
                and p.effective_end_date is not null
                and p.effective_date < p.effective_end_date
                and p.creation_date < p.effective_end_date
                and get_actual_balance(p.acc_id,
                                       p.plan_type,
                                       p.plan_start_date,
                                       last_day(p.effective_end_date + nvl(p.runout_period_days, 0))) > 0
                and last_day(
                    case
                        when p.runout_period_term = 'CPE' then
                            least(p.effective_end_date, p.plan_end_date) + nvl(p.runout_period_days, 0) -- Vanitha: 09/02/2018: ADDED LEAST CONDITION AS TERM DATES ARE ENTERED WELL AFTER PLAN ENDED
                        else p.plan_end_date + nvl(p.runout_period_days, 0)
                    end
                ) >= p_end_date
                and ( p.effective_end_date < p_start_date
                      or last_day(p.effective_end_date) + 1 between p_start_date and p_end_date )
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = c.acc_id
                        and plan_type = p.plan_type
                        and ben_plan_enrollment_setup.status in ( 'A', 'I' )
                        and plan_start_date > p.plan_end_date
                )
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = c.acc_id
                        and entrp_id = d.entrp_id
                        and invoice_id = p_invoice_id
                        and plan_type = p.plan_type
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and invoice_kind = 'RUNOUT_INVOICE_TERM'
                );

        pc_log.log_error('PC_INVOICE.proc_term_dist', 'No of rows processed ' || sql%rowcount);
    end proc_term_dist;

    procedure proc_term_credit (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is

        l_invoice_reason       varchar2(25);
        l_invoice_kind         varchar2(25);
        l_credit_given_cnt     number;
        l_un_termed_plan_cnt   number;
        l_invoice_type         varchar2(5);
        l_account_type         varchar2(5);
        l_app_exception exception;
        l_invoiced_but_termed  number;
        l_active_plan_cnt      number;
        l_term_adjusted_inv_id number;
        l_inv_rerun            varchar2(6);
    begin
        pc_log.log_error('PC_INVOICE.proc_term_credit', 'proc_term_credit begins');
    -- plan end dated/not renewed plans
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_status,
            plan_code,
            plan_type,
            effective_date,
            termination_date,
            termination_req_date,
            terminated,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            product_type,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                d.entrp_id,
                c.acc_id,
                c.pers_id,
                c.account_status,
                p.status,
                p.ben_plan_name --C.PLAN_CODE
                ,
                p.plan_type,
                p.effective_date,
                p.effective_end_date,
                p.termination_req_date,
                'Y',
                p.creation_date,
                'INVOICE'         invoice_reason,
                1                 invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'TERM_ADJUSTMENT' invoice_kind,
                p_start_date,
                p_end_date,
                p.product_type,
                d.division_code
            from
                ben_plan_enrollment_setup p,
                account                   c,
                person                    d
            where
                    p.acc_id = c.acc_id
                and c.pers_id = d.pers_id
                and d.entrp_id = p_entrp_id
                and p.status in ( 'A', 'I' )
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and d.division_code = g_division_code ) )
                and p.plan_end_date >= p_end_date
                and p.effective_end_date < p_start_date
                and p.plan_end_date >= p_end_date
            --		 and  p.plan_end_date < SYSDATE
                and p.effective_end_date is not null
                and p.effective_date < p.effective_end_date
                and p.creation_date < p.effective_end_date
                and nvl(p.runout_period_days, 0) > 0
                and p.termination_req_date > p.effective_end_date + nvl(p.runout_period_days, 0) + 30
                and p.termination_req_date between p_start_date and p_end_date
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = c.acc_id
                        and plan_type = p.plan_type
                        and plan_start_date > p.plan_end_date
                        and ben_plan_enrollment_setup.status in ( 'A', 'I' )
                )
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = c.acc_id
                        and entrp_id = d.entrp_id
                        and invoice_id = p_invoice_id
                        and plan_type = p.plan_type
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and invoice_kind = 'TERM_ADJUSTMENT'
                )
	      /*   and  exists ( select * from  AR_INVOICE_DIST_PLANS
		               where invoice_kind  ='ACTIVE'
			       and    acc_id = c.acc_id
			       and    invoice_id < P_INVOICE_ID)*/;

        pc_log.log_error('PC_INVOICE.proc_term_credit', 'No of rows processed ' || sql%rowcount);
    end proc_term_credit;

    procedure proc_debit_card_charge_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
    begin
        pc_log.log_error('PC_INVOICE.proc_debit_card_charge_dist', 'Process Distribution for Invoice ID ' || p_invoice_id);
         -- confirm if dep has to be charged
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_type,
            effective_date,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                p.entrp_id,
                a.acc_id,
                a.pers_id,
                a.account_status,
                null,
                a.start_date,
                c.start_date,
                'INVOICE'     invoice_reason,
                1             invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'CARD_CHARGE' invoice_kind,
                p_start_date,
                p_end_date,
                p.division_code
            from
                account    a,
                card_debit c,
                person     p
            where
                    p.entrp_id = p_entrp_id
                and p.pers_id = a.pers_id
                and a.pers_id = c.card_id
                and c.status in ( 2, 4 )
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and p.division_code = g_division_code ) )
                and (
                    select
                        count(*)
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = a.acc_id
                        and ben_plan_enrollment_setup.status = 'A'
                        and nvl(effective_end_date, plan_end_date) >= p_end_date
                    having count(*) > 0
                           and count(*) >= nvl(
                        sum(
                            case
                                when effective_end_date is not null then
                                    1
                                else 0
                            end
                        ),
                        0
                    )
                ) > 0 -- active and suspended
                and not exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = a.acc_id
                        and ben_plan_enrollment_setup.status = 'A'
                        and product_type = 'HRA'
                )
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = a.acc_id
                        and effective_date <= p_end_date
                        and ben_plan_enrollment_setup.status = 'A'
                )
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = a.acc_id
                        and entrp_id = p.entrp_id
                        and invoice_id = p_invoice_id
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and invoice_kind = 'CARD_CHARGE'
                );

        pc_log.log_error('PC_INVOICE.proc_debit_card_charge_dist', 'No of rows processed for distribution plan ' || sql%rowcount);
    end proc_debit_card_charge_dist;

    procedure proc_debit_card_issuance_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
    begin
        pc_log.log_error('PC_INVOICE.proc_debit_card_charge_dist', 'Process Distribution for Invoice ID ' || p_invoice_id);
         -- confirm if dep has to be charged
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_type,
            effective_date,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                p.entrp_id,
                a.acc_id,
                a.pers_id,
                a.account_status,
                null,
                a.start_date,
                c.start_date,
                'INVOICE'                             invoice_reason,
                pc_person.count_debit_card(p.pers_id) invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'CARD_ISSUANCE'                       invoice_kind,
                p_start_date,
                p_end_date,
                p.division_code
            from
                account    a,
                card_debit c,
                person     p
            where
                    p.entrp_id = p_entrp_id
                and p.pers_id = a.pers_id
                and a.pers_id = c.card_id
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and p.division_code = g_division_code ) )
                and c.status in ( 2, 4 ) -- active and suspended
                and c.issue_date between to_char(p_start_date, 'YYYYMMDD') and to_char(p_end_date, 'YYYYMMDD')
                and not exists (
                    select
                        1
                    from
                        metavante_cards mc_in
                    where
                            mc_in.acc_num = a.acc_num
                        and mc_in.status_code in ( 4, 5 )
                )
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = a.acc_id
                        and entrp_id = p.entrp_id
                        and invoice_id = p_invoice_id
                        and invoice_kind = 'CARD_ISSUANCE'
                );

        pc_log.log_error('PC_INVOICE.proc_debit_card_charge_dist', 'No of rows processed for distribution plan ' || sql%rowcount);
    end proc_debit_card_issuance_dist;

    procedure proc_lost_stolen_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
    begin
        pc_log.log_error('PC_INVOICE.proc_debit_card_charge_dist', 'Process Distribution for Invoice ID ' || p_invoice_id);
         -- confirm if dep has to be charged
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_type,
            effective_date,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                p.entrp_id,
                a.acc_id,
                a.pers_id,
                a.account_status,
                null,
                a.start_date,
                c.start_date,
                'INVOICE'                 invoice_reason,
                1                         invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'LOST_STOLEN_REPLACEMENT' invoice_kind,
                p_start_date,
                p_end_date,
                p.division_code
            from
                account    a,
                card_debit c,
                person     p
            where
                    p.entrp_id = p_entrp_id
                and p.pers_id = a.pers_id
                and a.pers_id = c.card_id
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and p.division_code = g_division_code ) )
                and c.status in ( 2, 4 ) -- active and suspended
                and c.issue_date between to_char(p_start_date, 'YYYYMMDD') and to_char(p_end_date, 'YYYYMMDD')
                and a.account_type in ( 'HRA', 'FSA' )
                and exists (
                    select
                        1
                    from
                        metavante_cards mc_in
                    where
                            mc_in.acc_num = a.acc_num
                        and mc_in.status_code = 5
                        and to_date(mc_in.card_expire_date, 'YYYYMMDD') > sysdate
                )
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = a.acc_id
                        and entrp_id = p.entrp_id
                        and invoice_id = p_invoice_id
                              -- and   plan_type = c.plan_type
                        and invoice_kind = 'LOST_STOLEN_REPLACEMENT'
                );

        pc_log.log_error('PC_INVOICE.proc_debit_card_charge_dist', 'No of rows processed for distribution plan ' || sql%rowcount);
    end proc_lost_stolen_dist;

    procedure proc_eob_charge_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
    begin
        pc_log.log_error('PC_INVOICE.proc_eob_charge_dist', 'Process Distribution for Invoice ID ' || p_invoice_id);
         -- confirm if dep has to be charged
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_type,
            effective_date,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                p.entrp_id,
                a.acc_id,
                a.pers_id,
                a.account_status,
                null,
                c.creation_date,
                c.creation_date,
                'INVOICE'    invoice_reason,
                1            invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'EOB_CHARGE' invoice_kind,
                p_start_date,
                p_end_date,
                p.division_code
            from
                account            a,
                person             p,
                account_preference c,
                insure             d
            where
                    p.entrp_id = p_entrp_id
                and p.pers_id = a.pers_id
                and p.entrp_id = c.entrp_id
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and p.division_code = g_division_code ) )
                and exists (
                    select
                        *
                    from
                        ben_plan_enrollment_setup
                    where
                            acc_id = a.acc_id
                        and ben_plan_enrollment_setup.status = 'A'
                        and last_day(decode(runout_period_term,
                                            'CPE',
                                            nvl(effective_end_date, plan_end_date),
                                            'CYE',
                                            plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0)) >= p_end_date
                )
                and c.allow_eob = 'Y'
                and d.pers_id = p.pers_id
                and d.allow_eob = 'Y'
                and d.carrier_supported = 'Y'
                and d.eob_connection_status = 'SUCCESS'
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = a.acc_id
                        and entrp_id = p.entrp_id
                        and invoice_id = p_invoice_id
                        and start_date = p_start_date
                        and end_date = p_end_date
                        and invoice_kind = 'EOB_CHARGE'
                );    -- allow_eob

        pc_log.log_error('PC_INVOICE.proc_eob_charge_dist', 'No of rows processed for distribution plan ' || sql%rowcount);
    end proc_eob_charge_dist;

    procedure proc_sf_ord_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
    begin
        pc_log.log_error('PC_INVOICE.proc_eob_charge_dist', 'Process Distribution for Invoice ID ' || p_invoice_id);
         -- confirm if dep has to be charged
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_type,
            effective_date,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                entrp_id,
                acc_id,
                pers_id,
                account_status,
                'HRA',
                start_date,
                start_date,
                'INVOICE'      invoice_reason,
                1              invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'SFORD_CHARGE' invoice_kind,
                p_start_date,
                p_end_date,
                division_code
            from
                (
                    select distinct
                        p.entrp_id,
                        a.acc_id,
                        a.pers_id,
                        a.account_status,
                        a.start_date,
                        nvl(g_division_code, '-1') division_code
                    from
                        account                   a,
                        person                    p,
                        ben_plan_enrollment_setup c
                    where
                            p.entrp_id = p_entrp_id
                        and p.pers_id = a.pers_id
                        and c.status in ( 'A', 'I' )
                        and c.product_type = 'HRA'
                        and ( ( g_division_code is null )
                              or ( g_division_code is not null
                                   and p.division_code = g_division_code ) )
                        and last_day(decode(runout_period_term,
                                            'CPE',
                                            nvl(effective_end_date, plan_end_date),
                                            'CYE',
                                            plan_end_date) + nvl(runout_period_days, 0) + nvl(grace_period, 0)) >= p_end_date
                        and c.sf_ordinance_flag = 'Y'
                        and c.acc_id = a.acc_id
                        and not exists (
                            select
                                *
                            from
                                ar_invoice_dist_plans
                            where
                                    acc_id = a.acc_id
                                and entrp_id = p.entrp_id
                                and invoice_id = p_invoice_id
                                and plan_type = c.plan_type
                                and start_date = p_start_date
                                and end_date = p_end_date
                                and invoice_kind = 'SFORD_CHARGE'
                        )
                );

        pc_log.log_error('PC_INVOICE.proc_eob_charge_dist', 'No of rows processed for distribution plan ' || sql%rowcount);
    end proc_sf_ord_dist;

    procedure proc_active_adj_dist (
        p_invoice_id in number,
        p_entrp_id   in number,
        p_start_date in date,
        p_end_date   in date
    ) is
    begin
        pc_log.log_error('PC_INVOICE.proc_active_dist', 'Process Distribution for Invoice ID ' || p_invoice_id);
        insert into ar_invoice_dist_plans (
            invoice_dist_plan_id,
            invoice_id,
            entrp_id,
            acc_id,
            pers_id,
            account_status,
            plan_status,
            plan_code,
            plan_type,
            effective_date,
            termination_date,
            termination_req_date
            --,RENEWAL_DATE
            ,
            terminated,
            enrolled_date,
            invoice_reason,
            invoice_days,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            invoice_kind,
            start_date,
            end_date,
            product_type,
            division_code
        )
            select
                ar_invoice_distribution_seq.nextval,
                p_invoice_id,
                p.entrp_id,
                a.acc_id,
                a.pers_id,
                a.account_status,
                c.status,
                c.ben_plan_name --C.PLAN_CODE
                ,
                c.plan_type,
                c.effective_date,
                c.effective_end_date,
                c.termination_req_date
                --,  C.RENEWAL_DATE
                ,
                c.terminated,
                c.creation_date,
                'INVOICE'                                                     invoice_reason,
                trunc((trunc(c.creation_date, 'MM') - c.effective_date) / 30) invoice_days,
                sysdate,
                0,
                sysdate,
                0,
                'ACTIVE_ADJUSTMENT'                                           invoice_kind,
                p_start_date,
                p_end_date,
                c.product_type,
                p.division_code
            from
                account                   a,
                ben_plan_enrollment_setup c,
                person                    p
            where
                    p.entrp_id = p_entrp_id
                and p.pers_id = a.pers_id
                and a.acc_id = c.acc_id
                and ( ( g_division_code is null )
                      or ( g_division_code is not null
                           and p.division_code = g_division_code ) )
                and c.effective_date between c.plan_start_date and c.plan_end_date
                and c.status in ( 'A', 'I' )
                and c.plan_end_date >= p_end_date
                and c.creation_date between p_start_date and p_end_date
                and ( c.effective_end_date is null
                      or c.effective_end_date between p_start_date and p_end_date
                      or ( c.effective_end_date > p_end_date
                           and c.effective_end_date <= c.plan_end_date ) )
                and c.effective_date < nvl(c.effective_end_date, c.plan_end_date)  --effective date should be earlier than termination date
                and c.effective_date < p_start_date
                and trunc((trunc(c.creation_date, 'MM') - c.effective_date) / 30) > 0
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans d
                    where
                            acc_id = a.acc_id
                        and entrp_id = p.entrp_id
                        and invoice_id < p_invoice_id
                        and invoice_kind in ( 'RUNOUT_PLAN_YEAR', 'RUNOUT_INVOICE_TERM', 'GRACE_ACTIVE' )
                        and plan_type = c.plan_type
                )
                and not exists (
                    select
                        *
                    from
                        ar_invoice_dist_plans
                    where
                            acc_id = a.acc_id
                        and entrp_id = p.entrp_id
                        and invoice_id = p_invoice_id
                        and plan_type = c.plan_type
                        and invoice_kind = 'ACTIVE_ADJUSTMENT'
                );

        pc_log.log_error('PC_INVOICE.proc_active_adj_dist', 'No of rows processed for distribution plan ' || sql%rowcount);
    end proc_active_adj_dist;

    procedure post_invoice (
        p_transaction_id in number
    ) is
        l_invoice_id number;
    begin
        for x in (
            select
                at.invoice_id,
                at.total_amount,
                at.transaction_id,
                at.transaction_date
            from
                ar_invoice   ar,
                ach_transfer at
            where
                    at.transaction_id = p_transaction_id
                and ar.status = 'PROCESSED'
                and at.status = 3
                and ar.invoice_reason in ( 'FEE', 'FUNDING', 'CLAIM' )
                and upper(at.bankserv_status) = 'APPROVED'
                and ar.entity_type = 'EMPLOYER'
                and at.invoice_id = ar.invoice_id
        ) loop
            pc_log.log_error('pc_invoice', 'post_invoice x.invoice_id '
                                           || x.invoice_id
                                           || 'x.transaction_id :='
                                           || x.transaction_id);

            pc_invoice.post_invoices(
                p_invoice_id     => x.invoice_id,
                p_check_number   => x.transaction_id,
                p_check_amount   => x.total_amount,
                p_payment_method => 5,
                p_check_date     => x.transaction_date,
                p_user_id        => 0,
                p_paid_by        => 'NONE'
            ); -- added by Joshi for 8692	);
            l_invoice_id := x.invoice_id;
        end loop;

        for x in (
            select
                invoice_id,
                sum(nvl(check_amount, 0)) check_amount
            from
                (
                    select
                        a.invoice_id,
                        sum(b.check_amount) check_amount
                    from
                        ar_invoice        a,
                        employer_deposits b,
                        ach_transfer      c
                    where
                            a.invoice_id = b.invoice_id
                        and c.transaction_id = p_transaction_id
                        and a.invoice_id = c.invoice_id
                        and c.bankserv_status = 'APPROVED'
                        and a.invoice_reason = 'CLAIM'
                        and c.status = 3
                    group by
                        a.invoice_id
                )
            group by
                invoice_id
        ) loop
            update ar_invoice
            set
                paid_amount = nvl(x.check_amount, 0),
                pending_amount = invoice_amount - nvl(void_amount, 0) - ( nvl(x.check_amount, 0) )
            where
                invoice_id = x.invoice_id;

            update ar_invoice
            set
                status = 'POSTED'
            where
                    invoice_reason = 'CLAIM'
                and paid_amount = invoice_amount - nvl(void_amount, 0)
                                                   and invoice_id = x.invoice_id;

            insert into claim_invoice_posting (
                invoice_posting_id,
                invoice_id,
                claim_id,
                payment_amount,
                posting_status,
                creation_date,
                created_by
            )
                select
                    claim_invoice_posting_seq.nextval,
                    invoice_id,
                    entity_id,
                    rate_amount,
                    'NOT_POSTED',
                    sysdate,
                    0
                from
                    invoice_distribution_summary
                where
                        invoice_id = x.invoice_id
                    and rate_code in ( 11, 12, 19 )
                    and not exists (
                        select
                            *
                        from
                            claim_invoice_posting ci
                        where
                                ci.invoice_id = invoice_distribution_summary.invoice_id
                            and ci.claim_id = invoice_distribution_summary.entity_id
                    );
              -- as soon as we get the payment we will go ahead and release it
            release_invoiced_claims(x.invoice_id);
        end loop;

        for x in (
            select
                at.invoice_id,
                at.total_amount,
                at.transaction_id,
                at.transaction_date,
                ar.entity_id
            from
                ar_invoice   ar,
                ach_transfer at
            where
                    at.transaction_id = p_transaction_id
                and ar.status = 'IN_PROCESS'
                and at.status = 3
                and ar.invoice_reason = 'PREMIUM'
                and upper(at.bankserv_status) = 'APPROVED'
                and ar.entity_type = 'PERSON'
                and at.invoice_id = ar.invoice_id
        ) loop
            pc_invoice.post_premium(
                p_transaction_id => x.transaction_id,
                p_invoice_id     => x.invoice_id
            ); -- added by Joshi for 8692	);

          --    pc_events.process_election_status_event(x.invoice_id, null);

            l_invoice_id := x.invoice_id;
        end loop;

    end post_invoice;

    procedure post_check_invoice (
        p_invoice_id     in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_method in varchar2,
        p_check_date     in date,
        p_user_id        in number
    ) is

        l_other_fee_exists varchar2(30);
        l_monthly_fee      number := 0;
        l_other_fee        number := 0;
        l_deposit          number := 0;
        l_total_amount     number := 0;
        l_invoice_amount   number := 0;
        l_remaining_amount number := 0;
    begin
        l_monthly_fee := 0;
        l_other_fee := 0;
        l_deposit := 0;
        l_total_amount := 0;
        l_invoice_amount := p_check_amount;
        select
            ar.invoice_amount - ( nvl(ar.void_amount, 0) + nvl(ar.paid_amount, 0) ) pending_amount
        into l_remaining_amount
        from
            ar_invoice ar
        where
            invoice_id = p_invoice_id;

        for x in (
            select
                invoice_id,
                entrp_id,
                plan_type,
                start_date,
                end_date,
                sum(invoice_amount) invoice_amount,
                reason_code,
                sum(partial_amount) partial_amount
            from
                (
                    select
                        ar.invoice_id,
                        ar.entity_id          entrp_id,
                        case
                            when pr.plan_type in ( 'FSA_COMBO', 'TRN_PKG', 'FSA', 'DCA', 'IIR',
                                                   'LPF', 'PKG', 'TRN', 'UA1', 'TP2' ) then
                                'FSA'
                            when pr.plan_type = 'HRA' then
                                'HRA'
                            else
                                pr.plan_type
                        end                   plan_type,
                        arl.total_line_amount invoice_amount,
                        case
                            when arl.status = 'PARTIALLY_POSTED' then
                                arl.total_line_amount
                            else
                                0
                        end                   partial_amount,
                        ar.start_date,
                        ar.end_date,
                        case
                            when pr.reason_code in ( 43, 44 ) then
                                1
                            when pr.reason_code in ( 45, 46 ) then
                                30
                            when pr.reason_code in ( 31, 32, 33, 34, 35,
                                                     36, 37, 38, 39, 2,
                                                     40 ) then
                                2
                            when pr.reason_mapping = - 1 then
                                3
                            else
                                pr.reason_code
                        end                   reason_code
                    from
                        ar_invoice         ar,
                        ar_invoice_lines   arl,
                        invoice_parameters a,
                        pay_reason         pr
                    where
                            ar.invoice_id = p_invoice_id
                        and ar.invoice_id = arl.invoice_id
                        and a.rate_plan_id = ar.rate_plan_id
                        and a.entity_id = ar.entity_id
                        and a.status = 'A'
                        and arl.rate_code = to_char(pr.reason_code)
                        and a.invoice_type = ar.invoice_reason
                        and ar.entity_type = 'EMPLOYER'
                        and arl.status not in ( 'POSTED', 'VOID' )
                        and ar.status <> 'VOID'
                    order by
                        1
                )
            group by
                invoice_id,
                entrp_id,
                plan_type,
                reason_code,
                start_date,
                end_date
            order by
                reason_code asc
        ) loop
            if l_invoice_amount > 0 then
                if x.reason_code = 3 then
                    insert into employer_deposits (
                        employer_deposit_id,
                        entrp_id,
                        list_bill,
                        check_number,
                        check_amount,
                        check_date,
                        posted_balance,
                        remaining_balance,
                        fee_bucket_balance,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        note,
                        pay_code,
                        reason_code,
                        plan_type,
                        invoice_id
                    ) values ( employer_deposit_seq.nextval,
                               x.entrp_id,
                               employer_deposit_seq.currval,
                               p_check_number,
                               x.invoice_amount,
                               p_check_date,
                               x.invoice_amount,
                               0,
                               0,
                               p_user_id,
                               sysdate,
                               p_user_id,
                               sysdate,
                               'Inserted from Invoice '
                               || x.invoice_id
                               || ' for check number '
                               || p_check_number
                               || ' with amount '
                               || p_check_amount
                               || ' for '
                               || to_char(x.start_date, 'MM/DD/YYYY')
                               || ' - '
                               || to_char(x.end_date, 'MM/DD/YYYY'),
                               p_payment_method,
                               3,
                               x.plan_type,
                               x.invoice_id );

                    l_invoice_amount := l_invoice_amount - x.invoice_amount;
                    l_remaining_amount := l_remaining_amount - x.invoice_amount;
                else
                    if
                        l_remaining_amount > 0
                        and l_invoice_amount > 0
                    then
                        insert into employer_payments (
                            employer_payment_id,
                            entrp_id,
                            check_amount,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by
                        --,NOTE
                            ,
                            check_date,
                            check_number,
                            payment_register_id,
                            list_bill,
                            reason_code,
                            transaction_date,
                            plan_type,
                            pay_code,
                            invoice_id,
                            note
                        )
                            select
                                employer_payments_seq.nextval,
                                x.entrp_id,
                                least(x.invoice_amount, l_invoice_amount),
                                sysdate,
                                p_user_id,
                                sysdate,
                                p_user_id,
                                p_check_date,
                                p_check_number
                        --,p_user_id
                        --,note
                                ,
                                null,
                                null,
                                x.reason_code,
                                p_check_date,
                                x.plan_type,
                                p_payment_method,
                                x.invoice_id,
                                'Inserted from Invoice '
                                || x.invoice_id
                                || ' for check number '
                                || p_check_number
                                || ' with amount '
                                || p_check_amount
                                || ' for '
                                || to_char(x.start_date, 'MM/DD/YYYY')
                                || ' - '
                                || to_char(x.end_date, 'MM/DD/YYYY')
                            from
                                dual;

                        l_invoice_amount := l_invoice_amount - x.invoice_amount;
                        l_remaining_amount := l_remaining_amount - x.invoice_amount;
                        dbms_output.put_line('X.REASON_CODE '
                                             || x.reason_code
                                             || ' l_invoice_amount '
                                             || l_invoice_amount);
                        dbms_output.put_line('X.REASON_CODE '
                                             || x.reason_code
                                             || ' l_remaining_amount '
                                             || l_remaining_amount);
                    end if;
                end if;

            end if;
        end loop;

        for x in (
            select
                a.invoice_id,
                a.invoice_amount,
                a.void_amount,
                a.paid_amount,
                a.pending_amount,
                sum(b.check_amount) check_amount
            from
                ar_invoice        a,
                employer_payments b
            where
                    a.invoice_id = b.invoice_id
                and a.invoice_id = p_invoice_id
            group by
                a.invoice_id,
                a.invoice_amount,
                a.void_amount,
                a.paid_amount,
                a.pending_amount
        ) loop
            update ar_invoice
            set
                paid_amount = nvl(paid_amount, 0) + x.check_amount,
                pending_amount = x.invoice_amount - nvl(x.void_amount, 0) - nvl(x.check_amount, 0)
            where
                invoice_id = x.invoice_id;

        end loop;

        for x in (
            select
                a.invoice_id,
                sum(b.check_amount)      check_amount,
                sum(c.total_line_amount) total_line_amount
            from
                ar_invoice        a,
                employer_deposits b,
                ar_invoice_lines  c
            where
                    a.invoice_id = b.invoice_id
                and c.invoice_id = a.invoice_id
                and a.invoice_id = p_invoice_id
                and c.rate_code in ( 180, 49 )
                and c.status <> 'VOID'
            group by
                a.invoice_id
        ) loop
            update ar_invoice_lines
            set
                status =
                    case
                        when x.check_amount < x.total_line_amount then
                            'PARTIALLY_POSTED'
                        when x.check_amount = x.total_line_amount then
                            'POSTED'
                    end
            where
                    invoice_id = x.invoice_id
                and rate_code in ( 180, 49 );

        end loop;

        update ar_invoice
        set
            status =
                case
                    when paid_amount = invoice_amount + nvl(void_amount, 0) then
                        'POSTED'
                    when paid_amount > 0
                         and paid_amount < invoice_amount + nvl(void_amount, 0) then
                        'PARTIALLY_POSTED'
                end
        where
            invoice_id = p_invoice_id;

        for x in (
            select
                x.invoice_id,
                x.entrp_id,
                x.plan_type,
                x.start_date,
                x.end_date,
                sum(x.invoice_amount) invoice_amount,
                x.reason_code,
                c.check_amount
            from
                (
                    select
                        ar.invoice_id,
                        ar.entity_id          entrp_id,
                        case
                            when pr.plan_type in ( 'FSA_COMBO', 'TRN_PKG', 'FSA', 'DCA', 'IIR',
                                                   'LPF', 'PKG', 'TRN', 'UA1', 'TP2' ) then
                                'FSA'
                            when pr.plan_type = 'HRA' then
                                'HRA'
                            else
                                pr.plan_type
                        end                   plan_type,
                        arl.total_line_amount invoice_amount,
                        ar.start_date,
                        ar.end_date,
                        case
                            when pr.reason_code in ( 43, 44 ) then
                                1
                            when pr.reason_code in ( 45, 46 ) then
                                30
                            when pr.reason_code in ( 31, 32, 33, 34, 35,
                                                     36, 37, 38, 39, 2,
                                                     40 ) then
                                2
                            when pr.reason_mapping = - 1 then
                                3
                            else
                                pr.reason_code
                        end                   reason_code
                    from
                        ar_invoice         ar,
                        ar_invoice_lines   arl,
                        invoice_parameters a,
                        pay_reason         pr
                    where
                            ar.invoice_id = p_invoice_id
                        and ar.invoice_id = arl.invoice_id
                        and a.entity_id = ar.entity_id
                        and ar.rate_plan_id = a.rate_plan_id
                        and arl.rate_code = to_char(pr.reason_code)
                        and a.invoice_type = ar.invoice_reason
                        and ar.entity_type = 'EMPLOYER'
                        and a.status = 'A'
                        and arl.status not in ( 'POSTED', 'VOID' )
                        and ar.status <> 'VOID'
                    order by
                        1
                )                 x,
                employer_payments c
            where
                    c.invoice_id = x.invoice_id
                and x.reason_code = c.reason_code
            group by
                x.invoice_id,
                x.entrp_id,
                x.plan_type,
                x.reason_code,
                x.start_date,
                x.end_date,
                c.check_amount
            order by
                x.reason_code asc
        ) loop
            if x.reason_code = 2 then
                update ar_invoice_lines
                set
                    status =
                        case
                            when x.invoice_amount = x.check_amount then
                                'POSTED'
                            when x.check_amount > 0
                                 and x.invoice_amount > x.check_amount then
                                'PARTIALLY_POSTED'
                            else
                                status
                        end
                where
                    rate_code in ( 31, 32, 33, 34, 35,
                                   36, 37, 38, 39, 2,
                                   40 )
                    and invoice_id = p_invoice_id
                    and status <> 'VOID';

            end if;

            if
                x.reason_code = 1
                and x.plan_type = 'HRA'
            then
                update ar_invoice_lines
                set
                    status =
                        case
                            when x.invoice_amount = x.check_amount then
                                'POSTED'
                            when x.check_amount > 0
                                 and x.invoice_amount > x.check_amount then
                                'PARTIALLY_POSTED'
                            else
                                status
                        end
                where
                    rate_code in ( '88', '43' )
                    and invoice_id = p_invoice_id
                    and status <> 'VOID';

            end if;

            if
                x.reason_code = 1
                and x.plan_type = 'FSA'
            then
                update ar_invoice_lines
                set
                    status =
                        case
                            when x.invoice_amount = x.check_amount then
                                'POSTED'
                            when x.check_amount > 0
                                 and x.invoice_amount > x.check_amount then
                                'PARTIALLY_POSTED'
                            else
                                status
                        end
                where
                    rate_code in ( '88', '44' )
                    and invoice_id = p_invoice_id
                    and status <> 'VOID';

            end if;

            if
                x.reason_code = 30
                and x.plan_type = 'HRA'
            then
                update ar_invoice_lines
                set
                    status =
                        case
                            when x.invoice_amount = x.check_amount then
                                'POSTED'
                            when x.check_amount > 0
                                 and x.invoice_amount > x.check_amount then
                                'PARTIALLY_POSTED'
                            else
                                status
                        end
                where
                    rate_code in ( '88', '45' )
                    and invoice_id = p_invoice_id
                    and status <> 'VOID';

            end if;

            if
                x.reason_code = 30
                and x.plan_type = 'FSA'
            then
                update ar_invoice_lines
                set
                    status =
                        case
                            when x.invoice_amount = x.check_amount then
                                'POSTED'
                            when x.check_amount > 0
                                 and x.invoice_amount > x.check_amount then
                                'PARTIALLY_POSTED'
                            else
                                status
                        end
                where
                    rate_code in ( '88', '46' )
                    and invoice_id = p_invoice_id
                    and status <> 'VOID';

            end if;

            if x.reason_code not in ( 1, 30, 2 ) then
                update ar_invoice_lines
                set
                    status =
                        case
                            when x.invoice_amount = x.check_amount then
                                'POSTED'
                            when x.check_amount > 0
                                 and x.invoice_amount > x.check_amount then
                                'PARTIALLY_POSTED'
                            else
                                status
                        end
                where
                        rate_code = x.reason_code
                    and invoice_id = p_invoice_id
                    and status <> 'VOID';

            end if;

        end loop;

        for x in (
            select
                status
            from
                ar_invoice
            where
                    invoice_id = p_invoice_id
                and status = 'POSTED'
        ) loop
            update ar_invoice_lines
            set
                status = 'POSTED'
            where
                    invoice_id = p_invoice_id
                and status <> 'VOID';

        end loop;

    end post_check_invoice;

 -- We use this for runout/grace calcuations
    function get_actual_balance (
        p_acc_id     in number,
        p_plan_type  in varchar2,
        p_start_date in date,
        p_fee_date   in date
    ) return number is
        l_balance number := 0;
    begin
        for x in (
            select
                sum(amount) balance
            from
                balance_register a
            where
                    acc_id = p_acc_id
                and reason_mode <> 'C'
                and plan_type = p_plan_type
                and trunc(fee_date) between p_start_date and p_fee_date
        ) loop
            l_balance := x.balance;
        end loop;

        return nvl(l_balance, 0);
    end get_actual_balance;
  -- Called from APEX Screen
  /** 11/17/2016: Vanitha - Added per the request from Shavee to record void at line level **/
    procedure void_invoice_line (
        p_invoice_line_id in number,
        p_user_id         in number,
        p_note            in varchar2 default null,
        p_status          in varchar2 default null,
        p_void_reason     in varchar2 default null
    )   -- -- Added By Jaggi ##9377
     is
    begin
        update ar_invoice_lines
        set
            void_date =
                case
                    when p_status = 'VOID' then
                        sysdate
                    else
                        null
                end,
            cancelled_date =
                case
                    when p_status = 'CANCELLED' then
                        sysdate
                    else
                        null
                end,
            status =
                case
                    when p_status is not null then
                        p_status
                    else
                        'VOID'
                end,
            last_update_date = sysdate,
            last_updated_by = p_user_id,
            note = p_note,
            void_reason = p_void_reason     ------- Added By Jaggi ##9377
        where
            invoice_line_id = p_invoice_line_id;

    end void_invoice_line;

  -- Called from APEX Screen
    procedure void_invoice (
        p_invoice_id  in number,
        p_user_id     in number,
        p_note        in varchar2 default null,
        p_status      in varchar2 default null,
        p_void_reason in varchar2
    ) -- Added By Jaggi ##9377
     is
        l_approved_date date;
    begin
        update ar_invoice
        set
            void_date = nvl(void_date,
                            case
                                when
                                    p_status = 'VOID'
                                    and approved_date is not null
                                then
                                    sysdate --##9560 added by Joshi
                                when approved_date is not null then
                                    sysdate
                                else null
                            end
            ),
            cancelled_date =
                case
                    when p_status = 'CANCELLED'
                         and approved_date is null then
                        sysdate
                    when approved_date is null then
                        sysdate
                    else
                        null
                end,
            void_amount = invoice_amount,
            pending_amount = 0,
            status =
                case
                    when p_status = 'VOID'
                         and approved_date is null then
                        'CANCELLED'
                    when p_status = 'VOID'
                         and approved_date is not null then
                        'VOID'
                    when approved_date is null then
                        'CANCELLED'
                    else
                        'VOID'
                end,
            last_update_date = sysdate,
            last_updated_by = p_user_id,
            note = p_note,
            void_reason = p_void_reason
        where
            invoice_id = p_invoice_id
        returning approved_date into l_approved_date;

        update ar_invoice_lines
        set
            void_date =
                case
                    when p_status = 'VOID' then
                        sysdate
                    when l_approved_date is not null then
                        sysdate
                    else
                        null
                end,
            cancelled_date =
                case
                    when p_status = 'CANCELLED' then
                        sysdate
                    when l_approved_date is null then
                        sysdate
                    else
                        null
                end,
            status =
                case
                    when p_status is not null then
                        p_status
                    when l_approved_date is null then
                        'CANCELLED'
                    else
                        'VOID'
                end,
            last_update_date = sysdate,
            last_updated_by = p_user_id,
            note = p_note,
            void_reason = p_void_reason
        where
            invoice_id = p_invoice_id;

        pc_ach_transfer.void_invoice(p_invoice_id, p_user_id);
    end void_invoice;

  -- Called from Nightly process
    procedure generate_monthly_invoice as
        l_error_status  varchar2(3200);
        l_error_message varchar2(3200);
        l_batch_number  number;
    begin
        pc_invoice.generate_invoice(
            trunc(trunc(sysdate, 'MM') - 1,
                  'MM'),
            last_day(trunc(sysdate, 'MM') - 1),
            null,
            null,
            'HRA',
            l_error_status,
            l_error_message,
            'MONTHLY',
            null,
            l_batch_number
        );

        pc_invoice.generate_invoice(
            trunc(trunc(sysdate, 'MM') - 1,
                  'MM'),
            last_day(trunc(sysdate, 'MM') - 1),
            null,
            null,
            'FSA',
            l_error_status,
            l_error_message,
            'MONTHLY',
            null,
            l_batch_number
        );

        pc_invoice.generate_invoice(
            trunc(trunc(sysdate, 'MM') - 1,
                  'MM'),
            last_day(trunc(sysdate, 'MM') - 1),
            null,
            null,
            'CMP',
            l_error_status,
            l_error_message,
            'MONTHLY',
            null,
            l_batch_number
        );

      -- Added by Joshi for 8471. To generate monthly invoice for setup/renewal.
      -- billing frequency selected as MONTHLY.
        pc_invoice.generate_monthly_fee_comp(
            trunc(
                trunc(sysdate, 'MM'),
                'MM'
            ),
            last_day(trunc(sysdate, 'MM')),
            null,
            null,
            'COBRA',
            l_error_status,
            l_error_message,
            'MONTHLY',
            null,
            l_batch_number
        );

    end generate_monthly_invoice;

  -- FSA/HRA has minimum Invoice amounts
    function get_minimum_inv_amount (
        p_entrp_id     in number,
        p_plan_type    in varchar2,
        p_rate_plan_id in number default null
    ) return number is
        l_min_inv_amount number := 0;
    begin
        if p_rate_plan_id is null then
            for x in (
                select
                    case
                        when p_plan_type = 'FSA' then
                            nvl(min_inv_amount, 0)
                        when p_plan_type = 'HRA' then
                            nvl(min_inv_hra_amount, 0)
                        else
                            0
                    end min_inv_amount
                from
                    invoice_parameters
                where
                        entity_type = 'EMPLOYER'
                    and entity_id = p_entrp_id
                    and invoice_type = 'FEE'
            ) loop
                l_min_inv_amount := x.min_inv_amount;
            end loop;
        else
            for x in (
                select
                    case
                        when p_plan_type = 'FSA' then
                            nvl(min_inv_amount, 0)
                        when p_plan_type = 'HRA' then
                            nvl(min_inv_hra_amount, 0)
                        else
                            0
                    end min_inv_amount
                from
                    invoice_parameters
                where
                        entity_type = 'EMPLOYER'
                    and rate_plan_id = p_rate_plan_id
                    and invoice_type = 'FEE'
            ) loop
                l_min_inv_amount := x.min_inv_amount;
            end loop;
        end if;

        return l_min_inv_amount;
    end get_minimum_inv_amount;
  -- We use this to post invoice amount, called from APEX when payments posted
    procedure post_invoices (
        p_invoice_id     in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_method in varchar2,
        p_check_date     in date,
        p_user_id        in number,
        p_paid_by        in varchar2
    ) -- added by Joshi for 8692	)
     is

        l_invoice_post_amount number := 0;
        l_check_amount        number;
        l_entrp_id            number;
        l_status              varchar2(30);
        l_invoice_amount      number := 0;
        l_ar_inv_amt          number := 0;
        l_account_type        varchar2(30);
    begin
        l_invoice_post_amount := p_check_amount;
        for xx in (
            select
                invoice_reason,
                plan_type,
                entity_id                            entrp_id,
                start_date,
                end_date,
                invoice_id,
                invoice_amount - nvl(void_amount, 0) total_invoice_amount,
                paid_amount,
                pending_amount,
                acc_id
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
            l_account_type := pc_account.get_account_type(xx.acc_id);
            pc_log.log_error('pc_invoice', 'post_invoices XX.INVOICE_REASON ' || xx.invoice_reason);
            if xx.invoice_reason = 'CLAIM' then
                post_funding(
                    p_invoice_id     => xx.invoice_id,
                    p_plan_type      => xx.plan_type,
                    p_reason_code    => 4,
                    p_check_number   => p_check_number,
                    p_check_amount   => p_check_amount,
                    p_payment_amount => p_check_amount,
                    p_user_id        => p_user_id,
                    p_payment_method => p_payment_method,
                    p_entrp_id       => xx.entrp_id,
                    p_check_date     => p_check_date,
                    p_start_date     => xx.start_date,
                    p_end_date       => xx.end_date
                );

                pc_log.log_error('pc_invoice', 'post_invoices **1 p_check_amount '
                                               || p_check_amount
                                               || 'xx.total_invoice_amount :='
                                               || xx.total_invoice_amount);

                pc_log.log_error('pc_invoice', 'post_invoices **1 xx.paid_amount '
                                               || xx.paid_amount
                                               || 'XX.PENDING_AMOUNT :='
                                               || xx.pending_amount
                                               || 'p_check_amount :='
                                               || p_check_amount);

                if p_check_amount = xx.total_invoice_amount
                or (
                    xx.paid_amount > 0
                    and xx.pending_amount = p_check_amount
                ) -- Added by Vanitha
                 then
                    insert into claim_invoice_posting (
                        invoice_posting_id,
                        invoice_id,
                        claim_id,
                        payment_amount,
                        posting_status,
                        creation_date,
                        created_by
                    )
                        select
                            claim_invoice_posting_seq.nextval,
                            invoice_id,
                            entity_id,
                            rate_amount,
                            'NOT_POSTED',
                            sysdate,
                            0
                        from
                            invoice_distribution_summary
                        where
                                invoice_id = xx.invoice_id
                            and rate_code in ( 11, 12, 19 )
                            and not exists (
                                select
                                    *
                                from
                                    ach_transfer at
                                where
                                    at.invoice_id = xx.invoice_id
                            )
                            and not exists (
                                select
                                    *
                                from
                                    claim_invoice_posting ci
                                where
                                        ci.invoice_id = xx.invoice_id
                                    and ci.claim_id = invoice_distribution_summary.entity_id
                            );

                    for xxx in (
                        select
                            count(*) cnt
                        from
                            ach_transfer at
                        where
                            at.invoice_id = xx.invoice_id
                    ) loop
                        if xxx.cnt = 0 then
                        -- as soon as we get the payment we will go ahead and release it
                            release_invoiced_claims(xx.invoice_id);
                        end if;
                    end loop;

                else -- Vanitha: 10-13-2016: Pay what we invoice enhancement
                    pc_notifications.email_partially_paid_claim_inv(xx.invoice_id);
                end if;

            elsif xx.invoice_reason = 'PREMIUM' then
                insert into income (
                    change_num,
                    acc_id,
                    fee_date,
                    fee_code,
                    amount,
                    pay_code,
                    cc_number,
                    note,
                    amount_add,
                    ee_fee_amount,
                    list_bill,
                    transaction_type,
                    due_date
                )
                    select
                        change_seq.nextval,
                        acc_id,
                        p_check_date,
                        92,
                        0,
                        p_payment_method,
                        p_check_number,
                        'Premium posted on '
                        || sysdate
                        || ' for '
                        || to_char(start_date, 'MM/DD/YYYY')
                        || '-'
                        || to_char(end_date, 'MM/DD/YYYY'),
                        least(amount, p_check_amount),
                        least(fee_amount,
                              greatest(amount, p_check_amount) - amount),
                        invoice_id,
                        'I',
                        start_date
                    from
                        (
                            select
                                a.acc_id,
                                i.invoice_id,
                                sum(
                                    case
                                        when il.rate_code = 91 then
                                            il.total_line_amount
                                        else
                                            0
                                    end
                                ) amount,
                                sum(
                                    case
                                        when il.rate_code = 92 then
                                            il.total_line_amount
                                        else
                                            0
                                    end
                                ) fee_amount,
                                i.start_date,
                                i.end_date
                            from
                                ar_invoice       i,
                                ar_invoice_lines il,
                                account          a
                            where
                                    i.invoice_id = p_invoice_id
                                and i.invoice_reason = 'PREMIUM'
                                and i.entity_type = 'PERSON'
                                and i.entity_id = a.pers_id
                                and a.account_type = 'COBRA'
                                and il.status not in ( 'VOID', 'CANCELLED' )
                                and i.invoice_id = il.invoice_id
                                and not exists (
                                    select
                                        *
                                    from
                                        income
                                    where
                                            income.acc_id = a.acc_id
                                        and list_bill = i.invoice_id
                                        and fee_date = p_check_date
                                )
                            group by
                                a.acc_id,
                                i.invoice_id,
                                i.start_date,
                                i.end_date
                        );

                for x in (
                    select
                        nvl(amount, 0) + nvl(amount_add, 0) + nvl(ee_fee_amount, 0) amount_posted,
                        a.invoice_amount,
                        a.invoice_id,
                        a.entity_id
                    from
                        income     i,
                        ar_invoice a
                    where
                            list_bill = p_invoice_id
                        and i.list_bill = a.invoice_id
                        and i.acc_id = a.acc_id
                        and a.invoice_reason = 'PREMIUM'
                ) loop
                    update ar_invoice_lines
                    set
                        status =
                            case
                                when x.amount_posted = x.invoice_amount then
                                    'POSTED'
                                else
                                    'PARTIALLY_POSTED'
                            end
                    where
                            invoice_id = p_invoice_id
                        and status in ( 'PROCESSED', 'IN_PROCESS' );

                    update ar_invoice
                    set
                        status =
                            case
                                when x.amount_posted = x.invoice_amount then
                                    'POSTED'
                                else
                                    'PARTIALLY_POSTED'
                            end,
                        paid_amount = x.amount_posted,
                        pending_amount = invoice_amount - x.amount_posted
                    where
                            invoice_id = p_invoice_id
                        and status in ( 'PROCESSED', 'IN_PROCESS' );

                end loop;

                pc_events.process_election_status_event(p_invoice_id, null);
            else

          --    IF p_check_amount >= XX.TOTAL_INVOICE_AMOUNT THEN
                for x in (
                    select
                        invoice_id,
                        entrp_id,
                        plan_type,
                        reason_code,
                        total_inv_amount,
                        reason_type,
                        case
                            when payment_amount > 0
                                 and invoice_amount >= payment_amount
                                 and reason_type <> 'RECEIPT' then
                                invoice_amount - nvl(payment_amount, 0)
                            when deposit_amount > 0
                                 and reason_type = 'RECEIPT' then
                                invoice_amount - nvl(deposit_amount, 0)
                            when payment_amount > 0
                                 and invoice_amount < payment_amount
                                 and reason_type <> 'RECEIPT' then
                                total_inv_amount - nvl(payment_amount, 0)
                            else
                                invoice_amount
                        end                                                                  invoice_amount,
                        pc_invoice.get_minimum_inv_amount(entrp_id, plan_type, rate_plan_id) minium_inv_amount,
                        start_date,
                        end_date
                    from
                        (
                            select
                                ar.invoice_id,
                                ar.entity_id                               entrp_id,
                                nvl(pr.product_type, arl.product_type)     plan_type,
                                ar.invoice_amount - nvl(ar.void_amount, 0) total_inv_amount,
                                sum(arl.total_line_amount)                 invoice_amount,
                                pr.reason_mapping                          reason_code,
                                pr.reason_type,
                                nvl(
                                    case
                                        when pr.reason_type = 'RECEIPT' then
                                            (
                                                select
                                                    sum(check_amount)
                                                from
                                                    employer_deposits
                                                where
                                                        invoice_id = ar.invoice_id
                                                    and plan_type = pr.product_type
                                            )
                                    end,
                                    0)                                     deposit_amount,
                                nvl(
                                    case
                                        when pr.reason_type <> 'RECEIPT' then
                                            (
                                                select
                                                    sum(check_amount)
                                                from
                                                    employer_payments
                                                where
                                                        invoice_id = ar.invoice_id
                                                    and reason_code = pr.reason_mapping
                                                    and plan_type = nvl(pr.product_type, plan_type)
                                                    and reason_code not in(23, 25)
                                            ) - nvl((
                                                select
                                                    sum(check_amount)
                                                from
                                                    employer_payments
                                                where
                                                        invoice_id = ar.invoice_id
                                                    and reason_code in(23, 25)
                                            ),
                                                    0)
                                    end,
                                    0)                                     payment_amount,
                                ar.start_date,
                                ar.end_date,
                                ar.rate_plan_id
                            from
                                ar_invoice         ar,
                                ar_invoice_lines   arl,
                                invoice_parameters a,
                                pay_reason         pr
                            where
                                    ar.invoice_id = p_invoice_id
                                and ar.invoice_id = arl.invoice_id
                                and a.entity_id = ar.entity_id
                                and a.rate_plan_id = ar.rate_plan_id
                                and arl.rate_code = to_char(pr.reason_code)
                                and ar.entity_type = 'EMPLOYER'
                                and arl.status not in ( 'VOID' )
                                and a.status = 'A'
                                and a.invoice_type = ar.invoice_reason
                                and ar.status not in ( 'POSTED', 'VOID' )
                                and arl.total_line_amount > 0
                            group by
                                ar.invoice_id,
                                ar.entity_id,
                                pr.product_type,
                                arl.product_type,
                                pr.reason_mapping,
                                pr.reason_type,
                                ar.start_date,
                                ar.end_date,
                                ar.invoice_amount,
                                nvl(ar.void_amount, 0),
                                ar.rate_plan_id
                            order by
                                pr.reason_mapping
                        )
                ) loop
                    l_invoice_amount := l_invoice_amount + nvl(x.invoice_amount, 0);
                    if l_invoice_amount < p_check_amount then
                        l_check_amount := nvl(x.invoice_amount, 0);
                    else
                        l_check_amount := least(
                            nvl(x.invoice_amount, 0),
                            l_invoice_post_amount
                        );
                    end if;

                    l_invoice_post_amount := l_invoice_post_amount - nvl(x.invoice_amount, 0);
                    if l_check_amount > 0 then
                        if x.reason_type = 'RECEIPT' then
                            post_funding(
                                p_invoice_id     => x.invoice_id,
                                p_plan_type      => x.plan_type,
                                p_reason_code    =>
                                               case
                                                   when x.reason_code = - 1 then
                                                       3
                                                   else
                                                       4
                                               end,
                                p_check_number   => p_check_number,
                                p_check_amount   => p_check_amount,
                                p_payment_amount => l_check_amount,
                                p_user_id        => p_user_id,
                                p_payment_method => p_payment_method,
                                p_entrp_id       => x.entrp_id,
                                p_check_date     => p_check_date,
                                p_start_date     => x.start_date,
                                p_end_date       => x.end_date
                            );
                        else
                            pc_log.log_error('PC_INVOICE.post_fees', 'invoice id: ' || x.invoice_id);
                            post_fees(
                                p_invoice_id     => x.invoice_id,
                                p_plan_type      => nvl(x.plan_type, l_account_type),
                                p_reason_code    => x.reason_code,
                                p_check_number   => p_check_number,
                                p_check_amount   => p_check_amount,
                                p_payment_amount => l_check_amount,
                                p_user_id        => p_user_id,
                                p_payment_method => p_payment_method,
                                p_entrp_id       => x.entrp_id,
                                p_check_date     => p_check_date,
                                p_start_date     => x.start_date,
                                p_end_date       => x.end_date,
                                p_paid_by        => p_paid_by  -- Added by Joshi for 8692
                            );

                        end if;

                        if x.reason_code <> 2 then
                            update ar_invoice_lines
                            set
                                status = 'POSTED'
                            where
                                    invoice_id = x.invoice_id
                                and total_line_amount = l_check_amount
                                and rate_code in (
                                    select
                                        to_char(reason_code)
                                    from
                                        pay_reason
                                    where
                                        ( product_type is null
                                          or product_type = x.plan_type )
                                        and reason_mapping = x.reason_code
                                )
                                and status not in ( 'VOID', 'CANCELLED' );

                            update ar_invoice_lines
                            set
                                status = 'PARTIALLY_POSTED'
                            where
                                    invoice_id = x.invoice_id
                                and status <> 'POSTED'
                                and total_line_amount > l_check_amount
                                and rate_code in (
                                    select
                                        to_char(reason_code)
                                    from
                                        pay_reason
                                    where
                                        ( product_type is null
                                          or product_type = x.plan_type )
                                        and reason_mapping = x.reason_code
                                )
                                and status not in ( 'VOID', 'CANCELLED' );

                        else
                            for xx in (
                                select
                                    invoice_line_id,
                                    case
                                        when l_check_amount - sum(total_line_amount)
                                                              over(
                                            order by
                                                total_line_amount
                                            range between unbounded preceding and current row
                                                              ) >= 0 then
                                            'POSTED'
                                        else
                                            'PARTIALLY_POSTED'
                                    end status
                                from
                                    ar_invoice_lines
                                where
                                        invoice_id = x.invoice_id
                                    and status in ( 'GENERATED', 'PARTIALLY_POSTED', 'PROCESSED' )
                                    and rate_code in (
                                        select
                                            to_char(reason_code)
                                        from
                                            pay_reason
                                        where
                                            ( product_type is null
                                              or product_type = x.plan_type )
                                            and reason_mapping = x.reason_code
                                    )
                                    and status not in ( 'VOID', 'CANCELLED' )
                            ) loop
                                update ar_invoice_lines
                                set
                                    status = xx.status
                                where
                                    invoice_line_id = xx.invoice_line_id;

                            end loop;
                        end if;

                        if l_account_type = 'POP' then
                            pc_employer_fin.activate_pop_account(xx.entrp_id);
                        end if;
                    end if;

                end loop;

        --   dbms_output.put_line('check amount '||l_check_amount);

                if l_invoice_post_amount > 0 then
                    for x in (
                        select
                            invoice_id,
                            entity_id,
                            invoice_amount,
                            sum(nvl(check_amount, 0))                                  check_amount,
                            void_amount,
                            plan_type,
                            get_minimum_inv_amount(entity_id, plan_type, rate_plan_id) min_inv_amount
                        from
                            (
                                select
                                    a.invoice_id,
                                    a.invoice_amount,
                                    a.entity_id,
                                    b.plan_type,
                                    nvl(a.void_amount, 0) void_amount,
                                    sum(
                                        case
                                            when b.reason_code in(23, 25) then
                                                - b.check_amount
                                            else
                                                b.check_amount
                                        end
                                    )                     check_amount,
                                    a.rate_plan_id
                                from
                                    ar_invoice        a,
                                    employer_payments b
                                where
                                        a.invoice_id = b.invoice_id
                                    and a.invoice_id = p_invoice_id
                                group by
                                    a.invoice_id,
                                    a.invoice_amount,
                                    a.entity_id,
                                    nvl(a.void_amount, 0),
                                    b.plan_type,
                                    a.rate_plan_id
                                union all
                                select
                                    a.invoice_id,
                                    a.invoice_amount,
                                    a.entity_id,
                                    b.plan_type,
                                    nvl(a.void_amount, 0) void_amount,
                                    sum(b.check_amount)   check_amount,
                                    a.rate_plan_id
                                from
                                    ar_invoice        a,
                                    employer_deposits b
                                where
                                        a.invoice_id = b.invoice_id
                                    and a.invoice_id = p_invoice_id
                                group by
                                    a.invoice_id,
                                    a.invoice_amount,
                                    a.entity_id,
                                    nvl(a.void_amount, 0),
                                    b.plan_type,
                                    a.rate_plan_id
                            )
                        group by
                            invoice_id,
                            invoice_amount,
                            entity_id,
                            void_amount,
                            plan_type,
                            rate_plan_id
                    ) loop
                        if
                            l_invoice_post_amount > 0
                            and l_invoice_post_amount <= ( x.min_inv_amount - x.check_amount )
                        then
                            update employer_payments
                            set
                                check_amount = check_amount + l_invoice_post_amount
                            where
                                    invoice_id = x.invoice_id
                                and reason_code = 2
                                and plan_type = x.plan_type;

                            update ar_invoice
                            set
                                paid_amount = nvl(x.check_amount, 0) + nvl(l_invoice_post_amount, 0),
                                pending_amount =
                                    case
                                        when invoice_amount - nvl(void_amount, 0) - ( nvl(x.check_amount, 0) + nvl(l_invoice_post_amount
                                        , 0) ) >= 0 then
                                            invoice_amount - nvl(void_amount, 0) - ( nvl(x.check_amount, 0) + nvl(l_invoice_post_amount
                                            , 0) )
                                        else
                                            0
                                    end
                            where
                                invoice_id = x.invoice_id;

                            l_check_amount := 0;
                        end if;
                    end loop;

                end if;

            end if;

            for x in (
                select
                    invoice_id,
                    sum(nvl(check_amount, 0)) check_amount
                from
                    (
                        select
                            a.invoice_id,
                            sum(
                                case
                                    when b.reason_code in(23, 25) then
                                        - b.check_amount
                                    else
                                        b.check_amount
                                end
                            ) check_amount
                        from
                            ar_invoice        a,
                            employer_payments b
                        where
                                a.invoice_id = b.invoice_id
                            and a.invoice_id = p_invoice_id
                        group by
                            a.invoice_id
                        union all
                        select
                            a.invoice_id,
                            sum(b.check_amount) check_amount
                        from
                            ar_invoice        a,
                            employer_deposits b
                        where
                                a.invoice_id = b.invoice_id
                            and a.invoice_id = p_invoice_id
                        group by
                            a.invoice_id
                    )
                group by
                    invoice_id
            ) loop
                update ar_invoice
                set
                    paid_amount = nvl(x.check_amount, 0),
                    pending_amount = invoice_amount - nvl(void_amount, 0) - ( nvl(x.check_amount, 0) )
                where
                    invoice_id = x.invoice_id;

            end loop;

            update ar_invoice
            set
                status =
                    case
                        when paid_amount = invoice_amount - nvl(void_amount, 0) then
                            'POSTED'
                        when paid_amount > 0
                             and paid_amount < invoice_amount - nvl(void_amount, 0) then
                            'PARTIALLY_POSTED'
                        else
                            status
                    end,
                approved_date = nvl(approved_date, sysdate),
                mailed_date = nvl(mailed_date, sysdate)
            where
                invoice_id = p_invoice_id;

        end loop;

    end post_invoices;

  -- When we collect Deposits/Funding we post to deposits
    procedure post_funding (
        p_invoice_id     in number,
        p_plan_type      in varchar2,
        p_reason_code    in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_amount in number,
        p_user_id        in number,
        p_payment_method in number,
        p_entrp_id       in number,
        p_check_date     in date,
        p_start_date     in date,
        p_end_date       in date
    ) is
        l_invoice_type varchar2(30);
    begin
        for xx in (
            select
                invoice_reason,
                plan_type,
                entity_id entrp_id,
                start_date,
                end_date,
                invoice_id
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
            l_invoice_type := initcap(xx.invoice_reason);
        end loop;

        pc_log.log_error('pc_invoice', 'post_funding INSERT INTO EMPLOYER_DEPOSITS p_invoice_id ' || p_invoice_id);
        insert into employer_deposits (
            employer_deposit_id,
            entrp_id,
            list_bill,
            check_number,
            check_amount,
            check_date,
            posted_balance,
            remaining_balance,
            fee_bucket_balance,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            note,
            pay_code,
            reason_code,
            plan_type,
            invoice_id
        ) values ( employer_deposit_seq.nextval,
                   p_entrp_id,
                   employer_deposit_seq.currval
                                --,case when p_payment_method = 5 THEN 'BankServ'||p_check_number
                   ,
                   case
                       when p_payment_method = 5 then
                           'CNB' || p_check_number  -- added by Joshi for NACHA process(7723)
                       else
                           p_check_number
                   end,
                   p_payment_amount,
                   p_check_date,
                   p_payment_amount,
                   0,
                   0,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   sysdate,
                   case
                       when p_payment_method = 5 then
                           'Funding for '
                           || l_invoice_type
                           || ' Invoice for Invoice# '
                           || p_invoice_id
                           || ' through ACH : Transaction_id '
                           || p_check_number
                           || ' for '
                           || to_char(p_start_date, 'MM/DD/YYYY')
                           || ' - '
                           || to_char(p_end_date, 'MM/DD/YYYY')
                       else
                           'Funding for '
                           || l_invoice_type
                           || ' Invoice Payment for Invoice# '
                           || p_invoice_id
                           || ' by check number '
                           || p_check_number
                           || ' with amount '
                           || p_check_amount
                           || ' for '
                           || to_char(p_start_date, 'MM/DD/YYYY')
                           || ' - '
                           || to_char(p_end_date, 'MM/DD/YYYY')
                   end,
                   p_payment_method,
                   p_reason_code,
                   p_plan_type,
                   p_invoice_id );

    end post_funding;

  -- Simple insert to Employer payments to record the fees
    procedure post_fees (
        p_invoice_id     in number,
        p_plan_type      in varchar2,
        p_reason_code    in number,
        p_check_number   in varchar2,
        p_check_amount   in number,
        p_payment_amount in number,
        p_user_id        in number,
        p_payment_method in number,
        p_entrp_id       in number,
        p_check_date     in date,
        p_start_date     in date,
        p_end_date       in date,
        p_paid_by        in varchar2
    ) is
        l_paid_by varchar2(100);
    begin

    -- Added by Joshi for 8692.
        for x in (
            select
                invoice_reason
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
            if x.invoice_reason <> 'FEE' then
                l_paid_by := 'EMPLOYER';
            elsif
                x.invoice_reason = 'FEE'
                and p_paid_by = 'NONE'
            then
                pc_log.log_error('p_reason_code', p_reason_code);
                if p_reason_code in ( 67, 68 ) then
                    l_paid_by := 'EMPLOYER';
                else
                    l_paid_by := null;
                    for y in (
                        select distinct
                            r.charged_to charged_to
                        from
                            ar_invoice       a,
                            rate_plan_detail r,
                            pay_reason       p
                        where
                                a.invoice_id = p_invoice_id
                            and a.rate_plan_id = r.rate_plan_id
                            and r.rate_code = p.reason_code
                            and nvl(p.reason_mapping, p.reason_code) = p_reason_code
                            and trunc(r.effective_date) <= a.end_date
                            and ( r.effective_end_date is null
                                  or r.effective_end_date >= a.end_date
                                  or r.effective_end_date between a.start_date and a.end_date )
                    ) loop
                        if y.charged_to is not null then
                            l_paid_by := y.charged_to;  -- added by Joshi 8692.
                        end if;
                    end loop;
                 -- added by Joshi 8692.
                end if;

            else
                l_paid_by := p_paid_by;
            end if;
        end loop;

      -- code ends here 8692.
        pc_log.log_error('pc_invoice.post_fees: p_invoice_id', p_invoice_id);
        insert into employer_payments (
            employer_payment_id,
            entrp_id,
            check_amount,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            check_date,
            check_number,
            reason_code,
            transaction_date,
            plan_type,
            pay_code,
            invoice_id,
            note,
            paid_by
        ) -- Added by Joshi for 8692
            select
                employer_payments_seq.nextval,
                p_entrp_id,
                p_payment_amount,
                sysdate,
                p_user_id,
                sysdate,
                p_user_id,
                p_check_date,
                p_check_number,
                p_reason_code,
                p_check_date,
                p_plan_type,
                p_payment_method,
                p_invoice_id,
                case
                    when p_payment_method = 5 then
                        'Payment through ACH : Transaction_id '
                        || p_check_number
                        || ' for '
                        || to_char(p_start_date, 'MM/DD/YYYY')
                        || ' - '
                        || to_char(p_end_date, 'MM/DD/YYYY')
                    when p_payment_method = 2 then -- Added by Joshi for 12255.
                        'Payment through Credit Card : Transaction_id '
                        || p_check_number
                        || ' for '
                        || to_char(p_start_date, 'MM/DD/YYYY')
                        || ' - '
                        || to_char(p_end_date, 'MM/DD/YYYY')
                    else
                        'Inserted from Invoice '
                        || p_invoice_id
                        || ' for check number '
                        || p_check_number
                        || ' with amount '
                        || p_check_amount
                        || ' for '
                        || to_char(p_start_date, 'MM/DD/YYYY')
                        || ' - '
                        || to_char(p_end_date, 'MM/DD/YYYY')
                end,
                l_paid_by
            from
                dual;

    end post_fees;

  -- Called from Bankserv process
    procedure post_ach_invoice (
        p_transaction_id in number
    ) is

        l_other_fee_exists varchar2(30);
        l_monthly_fee      number := 0;
        l_other_fee        number := 0;
        l_deposit          number := 0;
        l_total_amount     number := 0;
        l_invoice_id       number;
    begin
        l_monthly_fee := 0;
        l_other_fee := 0;
        l_deposit := 0;
        l_total_amount := 0;
        pc_log.log_error('PC_AUTO_PROCESS', 'Posting  invoice');
        for x in (
            select
                invoice_id,
                entrp_id,
                bank_acct_id,
                transaction_id,
                plan_type,
                start_date,
                end_date,
                sum(invoice_amount) invoice_amount,
                reason_code,
                pay_code,
                transaction_date,
                total_amount,
                reason_type
            from
                (
                    select
                        ar.invoice_id,
                        at.transaction_id,
                        ar.entity_id          entrp_id,
                        ar.plan_type,
                        arl.total_line_amount invoice_amount,
                        at.total_amount,
                        ar.bank_acct_id,
                        at.pay_code,
                        at.transaction_date,
                        ar.start_date,
                        ar.end_date,
                        case
                            when pr.reason_code in ( 1, 43, 44 ) then
                                1
                            when pr.reason_code in ( 45, 46 ) then
                                30
                            when pr.reason_code not in ( 1, 43, 44, 45, 46,
                                                         49, 180 ) then
                                2
                            when pr.reason_mapping = - 1 then
                                3
                            when pr.reason_mapping = - 2 then
                                4
                            else
                                pr.reason_code
                        end                   reason_code,
                        pr.reason_type
                    from
                        ar_invoice         ar,
                        ar_invoice_lines   arl,
                        invoice_parameters a,
                        pay_reason         pr,
                        ach_transfer       at
                    where
                            at.transaction_id = p_transaction_id
                        and ar.invoice_id = arl.invoice_id
                        and a.entity_id = ar.entity_id
                        and a.rate_plan_id = ar.rate_plan_id
                        and arl.rate_code = to_char(pr.reason_code)
                        and ar.status in ( 'POSTED', 'PROCESSED', 'PARTIALLY_POSTED' )
                        and a.invoice_type = ar.invoice_reason
                        and a.invoice_type = 'FEE'
                        and a.status = 'A'
        --   AND   ARL.STATUS =
                        and at.status = 3
                        and at.transaction_type = 'F'
                        and upper(at.bankserv_status) = 'APPROVED'
                        and ar.entity_type = 'EMPLOYER'
                        and at.invoice_id = ar.invoice_id
                    order by
                        1
                )
            group by
                invoice_id,
                entrp_id,
                bank_acct_id,
                transaction_id,
                plan_type,
                start_date,
                end_date,
                reason_code,
                pay_code,
                transaction_date,
                total_amount,
                reason_type
            order by
                reason_code desc
        ) loop
            l_total_amount := nvl(x.total_amount, 0);
            l_invoice_id := x.invoice_id;
            pc_log.log_error('PC_AUTO_PROCESS', 'Posting  EMPLOYER_DEPOSITS for reason code 3 ');
            if x.reason_type = 'RECEIPT' then
                insert into employer_deposits (
                    employer_deposit_id,
                    entrp_id,
                    list_bill,
                    check_number,
                    check_amount,
                    check_date,
                    posted_balance,
                    remaining_balance,
                    fee_bucket_balance,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    note,
                    pay_code,
                    reason_code,
                    plan_type
                ) values ( employer_deposit_seq.nextval,
                           x.entrp_id,
                           employer_deposit_seq.currval
                --,'BankServ'||p_transaction_id
                           ,
                           'CNB' || p_transaction_id  -- added by Joshi for NACHA process(7723)
                           ,
                           x.total_amount,
                           sysdate,
                           x.total_amount,
                           0,
                           0,
                           0,
                           sysdate,
                           0,
                           sysdate,
                           'Inserted from Invoice ' || x.invoice_id,
                           x.pay_code,
                           x.reason_code,
                           x.plan_type );

                update ar_invoice_lines
                set
                    status = 'POSTED'
                where
                        invoice_id = x.invoice_id
                    and status in ( 'PROCESSED', 'PARTIALLY_POSTED' )
                    and rate_code in (
                        select
                            reason_code
                        from
                            pay_reason
                        where
                                reason_type = x.reason_type
                            and reason_mapping = case
                                                     when x.reason_code = 3 then
                                                         - 1
                                                     else
                                                         - 2
                                                 end
                    );

                l_deposit := nvl(l_deposit, 0) + x.invoice_amount;
            else
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  EMPLOYER_DEPOSITS for reason code 1,30 ');
                if x.reason_code in ( 1, 30 ) then
                    l_other_fee := nvl(l_other_fee, 0) + x.invoice_amount;
                else
                    l_monthly_fee := nvl(l_monthly_fee, 0) + x.invoice_amount;
                end if;

                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  EMPLOYER_DEPOSITS for reason code 1,30 ' || l_other_fee);
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  EMPLOYER_DEPOSITS for reason code 1,30 ' || l_monthly_fee);
                if x.reason_code in ( 1, 30 ) then
                    insert into employer_payments (
                        employer_payment_id,
                        entrp_id,
                        check_amount,
                        creation_date
        --,CREATED_BY
                        ,
                        last_update_date
        --,LAST_UPDATED_BY
        --,NOTE
                        ,
                        check_date,
                        check_number,
                        bank_acct_id,
                        payment_register_id,
                        list_bill,
                        reason_code,
                        transaction_date,
                        plan_type,
                        pay_code,
                        invoice_id,
                        note
                    )
                        select
                            employer_payments_seq.nextval,
                            x.entrp_id,
                            x.total_amount,
                            sysdate
        --,p_user_id
                            ,
                            sysdate,
                            sysdate,
                            p_transaction_id
        --,p_user_id
        --,note
                            ,
                            x.bank_acct_id,
                            null,
                            null,
                            x.reason_code,
                            x.transaction_date,
                            x.plan_type,
                            x.pay_code,
                            x.invoice_id,
                            ': Payment through ACH : Transaction_id '
                            || p_transaction_id
                            || ' for '
                            || to_char(x.start_date, 'MM/DD/YYYY')
                            || ' - '
                            || to_char(x.end_date, 'MM/DD/YYYY')
                        from
                            dual
                        where
                            not exists (
                                select
                                    *
                                from
                                    employer_payments a
                                where
                                        a.invoice_id = x.invoice_id
                                    and reason_code = x.reason_code
                                    and pay_code = x.pay_code
                            );

                    pc_log.log_error('PC_AUTO_PROCESS', 'update ar invoice lines ');
                    update ar_invoice_lines
                    set
                        status = 'POSTED'
                    where
                            invoice_id = x.invoice_id
                        and status in ( 'PROCESSED', 'PARTIALLY_POSTED' )
                        and rate_code in ( '1', '43', '44', '45', '46',
                                           '88' );

                end if;

                if sql%rowcount = 0 then
                    update employer_payments
                    set
                        check_amount = x.total_amount
                    where
                            invoice_id = x.invoice_id
                        and reason_code = x.reason_code;

                end if;

            end if;

        end loop;

        pc_log.log_error('PC_AUTO_PROCESS', 'Posting  EMPLOYER_DEPOSITS for reminder ');
        if ( l_total_amount - ( l_deposit + l_other_fee ) ) >= 0 then
            pc_log.log_error('PC_AUTO_PROCESS', 'Posting  EMPLOYER_DEPOSITS for reminder '
                                                ||(l_total_amount -(l_deposit + l_other_fee)));

            for x in (
                select
                    b.entrp_id,
                    a.bank_acct_id,
                    a.transaction_date,
                    a.plan_type,
                    a.pay_code,
                    c.start_date,
                    c.end_date
                from
                    ach_transfer a,
                    account      b,
                    ar_invoice   c
                where
                        transaction_id = p_transaction_id
                    and a.invoice_id = c.invoice_id
                    and a.acc_id = b.acc_id
            ) loop
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  bank_acct_id ' || x.bank_acct_id);
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  plan_type ' || x.plan_type);
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  pay_code ' || x.pay_code);
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  entrp_id ' || x.entrp_id);
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  transaction_date ' || x.transaction_date);
                pc_log.log_error('PC_AUTO_PROCESS', 'Posting  invoice_id ' || l_invoice_id);
                insert into employer_payments (
                    employer_payment_id,
                    entrp_id,
                    check_amount,
                    creation_date
        --,CREATED_BY
                    ,
                    last_update_date
        --,LAST_UPDATED_BY
        --,NOTE
                    ,
                    check_date,
                    check_number,
                    bank_acct_id,
                    payment_register_id,
                    list_bill,
                    reason_code,
                    transaction_date,
                    plan_type,
                    pay_code,
                    invoice_id,
                    note
                )
                    select
                        employer_payments_seq.nextval,
                        x.entrp_id,
                        l_total_amount - ( l_deposit + l_other_fee ),
                        sysdate
        --,p_user_id
                        ,
                        sysdate,
                        sysdate,
                        to_char(p_transaction_id)
        --,p_user_id
        --,note
                        ,
                        x.bank_acct_id,
                        null,
                        null,
                        2,
                        x.transaction_date,
                        x.plan_type,
                        x.pay_code,
                        l_invoice_id,
                        ': Payment through ACH : Transaction_id '
                        || p_transaction_id
                        || ' for '
                        || to_char(x.start_date, 'MM/DD/YYYY')
                        || ' - '
                        || to_char(x.end_date, 'MM/DD/YYYY')
                    from
                        dual
                    where
                        not exists (
                            select
                                *
                            from
                                employer_payments a
                            where
                                    a.invoice_id = l_invoice_id
                                and reason_code = 2
                        )
                            and l_total_amount - ( l_deposit + l_other_fee ) > 0;

            end loop;

        end if;

        for x in (
            select
                sum(check_amount) total_amount,
                ar.invoice_id
            from
                ar_invoice        ar,
                ach_transfer      at,
                employer_payments ep
            where
                    at.transaction_id = p_transaction_id
                and at.invoice_id = ar.invoice_id
                and at.invoice_id = ep.invoice_id
                and ar.status in ( 'POSTED', 'PROCESSED', 'PARTIALLY_POSTED' )
                and at.status = 3
                and at.transaction_type = 'F'
                and upper(at.bankserv_status) = 'APPROVED'
                and ar.entity_type = 'EMPLOYER'
            group by
                ar.invoice_id
        ) loop
            update ar_invoice
            set
                status = 'POSTED',
                invoice_posted_date = sysdate,
                last_updated_by = 0,
                last_update_date = sysdate,
                paid_amount = x.total_amount,
                pending_amount = invoice_amount - void_amount - x.total_amount
            where
                invoice_id = x.invoice_id;

            update ar_invoice_lines
            set
                status = 'POSTED'
            where
                    invoice_id = x.invoice_id
                and status in ( 'PROCESSED', 'PARTIALLY_POSTED' );

        end loop;

    end post_ach_invoice;

   -- Called from pc_claim_automation every claim cycle to create claim invoice
    procedure generate_claim_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_product_type  in varchar2,
        x_error_status  out varchar2,
        x_error_message out varchar2,
        p_division_code in varchar2 default null
    ) is

        l_batch_number        number;
        l_error_message       varchar2(3200);
        l_invoice_id          number;
        l_app_inv_count       number := 0;
        l_div_invoicing_count number := 0;
        l_division_tab        varchar2_tbl;
        l_invoice_limit       number;
    begin
        l_division_tab(1) := null;
        begin
		     /* commented by Joshi on 23-MAR-2021.
              SELECT DISTINCT DIVISION_CODE BULK COLLECT INTO l_division_tab
                 FROM   RATE_PLANS WHERE ENTITY_ID = p_ENTRP_ID
                 AND  DIVISION_INVOICING = 'Y' AND STATUS = 'A'; */

            select distinct
                c.division_code
            bulk collect
            into l_division_tab
            from
                rate_plans         c,
                invoice_parameters a
            where
                    c.entity_id = p_entrp_id
                and c.division_invoicing = 'Y'
                and a.entity_type = 'EMPLOYER'
                and c.entity_id = a.entity_id
                and c.rate_plan_id = a.rate_plan_id
                and c.entity_type = a.entity_type
                and c.status = 'A'
                and a.status = 'A'
                and a.invoice_type = 'CLAIM';

        exception
            when no_data_found then
                l_division_tab(1) := null;
        end;

   /*       BEGIN

             SELECT DIVISION_CODE BULK COLLECT INTO l_division_tab
             FROM   EMPLOYER_DIVISIONS WHERE ENTRP_ID = p_ENTRP_ID;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                l_division_tab(1) := null;
          END;
          IF l_division_tab.COUNT > 0 THEN
              SELECT COUNT(*) INTO l_div_invoicing_count
              FROM RATE_PLANS WHERE ENTITY_ID = p_ENTRP_ID
              AND  DIVISION_INVOICING = 'Y';
          END IF;
          -- IF THE DIVISION INVOICING IS NOT SETUP FOR EMPLOYER WITH DIVISIONS
          -- WE WILL RUN AS IF IT IS NOT SETUP
          -- IF THE # OF DIVISION IS NOT MATCHING WITH # OF INVOICE SETUPS FOR DIVISIONS
          -- WE HAVE TO FIGURE OUT
          IF l_division_tab.COUNT > 0 AND l_div_invoicing_count <> l_division_tab.COUNT THEN
             l_division_tab.DELETE;
             l_division_tab(1) := null;
          END IF;*/
        if l_division_tab.count = 0 then
            l_division_tab(1) := null;
        end if;
        pc_log.log_error('generate_claim_invoice', 'entrp_id '
                                                   || p_entrp_id
                                                   || 'l_division_tab.count'
                                                   || l_division_tab.count);

          -- Added by Joshi for 10573. update payment to Wire transfer for invoices > 100K
        l_invoice_limit := pc_lookups.get_meaning('INVOICE_LIMIT', 'WIRE_TRANSFER_LIMIT');
        for i in 1..l_division_tab.count loop
            pc_log.log_error('generate_claim_invoice',
                             'division_code ' || l_division_tab(i));

   -- IF l_app_inv_count = 0 THEN
            select
                invoice_batch_seq.nextval
            into l_batch_number
            from
                dual;

            insert_ar_invoice(p_start_date,
                              p_end_date,
                              p_billing_date,
                              p_entrp_id,
                              p_product_type,
                              l_batch_number,
                              'CLAIM',
                              l_invoice_id,
                              l_division_tab(i));

            pc_log.log_error('generate_claim_invoice', 'INVOICE_ID ' || l_invoice_id);

              -- Gathers the data from Claim Auto process based on claims that is not released due to insufficient funds
            proc_claim_summary(
                p_invoice_id    => l_invoice_id,
                p_entrp_id      => p_entrp_id,
                p_start_date    => p_start_date,
                p_end_date      => p_end_date,
                p_product_type  => p_product_type,
                p_division_code => l_division_tab(i)
            );

            process_claim_invoice(
                p_start_date    => p_start_date,
                p_end_date      => p_end_date,
                p_invoice_id    => l_invoice_id,
                p_batch_number  => l_batch_number,
                x_error_status  => x_error_status,
                x_error_message => x_error_message
            );

            for x in (
                select
                    ar.invoice_id,
                    ar.entity_id,
                    sum(arl.total_line_amount) invoice_amount,
                    ar.rate_plan_id
                from
                    ar_invoice       ar,
                    ar_invoice_lines arl
                where
                        ar.batch_number = l_batch_number
                    and ar.invoice_id = arl.invoice_id
                    and ar.status = 'DRAFT'
                    and arl.status = 'DRAFT'
                group by
                    ar.invoice_id,
                    ar.entity_id,
                    ar.rate_plan_id
            ) loop
                update ar_invoice
                set
                    status = 'GENERATED',
                    invoice_amount = x.invoice_amount,
                    pending_amount = x.invoice_amount,
                    last_update_date = sysdate,
                    last_updated_by = 0
                             -- Added by Joshi for 10573. update payment to Wire transfer for invoices > 100K
                    ,
                    payment_method =
                        case
                            when x.invoice_amount >= l_invoice_limit then
                                'WIRE_TRANSFER'
                            else
                                payment_method
                        end,
                    bank_acct_id =
                        case
                            when x.invoice_amount >= l_invoice_limit then
                                null
                            else
                                bank_acct_id
                        end
                where
                    invoice_id = x.invoice_id;

                update ar_invoice_lines
                set
                    status = 'GENERATED',
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                    invoice_id = x.invoice_id;
                          -- set last invoiced date
                update invoice_parameters
                set
                    last_invoiced_date = sysdate
                where
                        entity_id = x.entity_id
                    and entity_type = 'EMPLOYER'
                    and invoice_type = 'CLAIM'
                    and rate_plan_id = x.rate_plan_id;

            end loop;

              -- Deleting the invoices that is in draft status
            delete from ar_invoice
            where
                not exists (
                    select
                        *
                    from
                        ar_invoice_lines
                    where
                        invoice_id = ar_invoice.invoice_id
                )
                    and status = 'DRAFT'
                    and trunc(creation_date) = trunc(sysdate)
                    and batch_number = l_batch_number;

        end loop;

    exception
    --  WHEN INVOICE_EXCEPTION THEN
    --    RAISE_APPLICATION_ERROR('-20001',l_error_message);
    --    rollback;
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            raise_application_error('-20001', x_error_message);
            pc_log.log_error('PC_INVOICE.generate_claim_invoice',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            rollback;
    end generate_claim_invoice;

    procedure process_claim_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_invoice_id    in number,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_invoice_line_id number;
    begin
        for xx in (
            select
                sum(nvl(rate_amount, 0)) amount,
                count(entity_id)         quantity,
                ids.rate_code,
                ids.account_type
                || ' '
                || p.reason_name         reason_name
            from
                invoice_distribution_summary ids,
                pay_reason                   p
            where
                    ids.invoice_id = p_invoice_id
                and ids.invoice_kind = 'CLAIM'
                and ids.invoice_reason = 'CLAIM'
                and ids.entity_type = 'CLAIMN'
                and ids.rate_code = p.reason_code
            group by
                ids.rate_code,
                p.reason_name,
                ids.account_type
        ) loop
            pc_invoice.insert_invoice_line(
                p_invoice_id        => p_invoice_id,
                p_invoice_line_type => 'CLAIM',
                p_rate_code         => xx.rate_code,
                p_description       => xx.reason_name,
                p_quantity          => xx.quantity,
                p_no_of_months      => 1,
                p_rate_cost         => xx.amount,
                p_total_cost        => xx.amount,
                p_batch_number      => p_batch_number,
                x_invoice_line_id   => l_invoice_line_id
            );

            update invoice_distribution_summary
            set
                invoice_line_id = l_invoice_line_id
            where
                    rate_code = xx.rate_code
                and invoice_id = p_invoice_id
                and invoice_kind = 'CLAIM';

        end loop;
    end process_claim_invoice;

-- Skeleton procedure to create skeleton invoice
-- Called from APEX to create manual invoice
-- Also used for creating claim invoice/funding invoice
    procedure insert_ar_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_batch_number   in number,
        p_invoice_reason in varchar2 default 'CLAIM',
        x_invoice_id     out number,
        p_division_code  in varchar2 default null
    ) is
        l_invoice_id   number;
        l_product_type varchar2(100);
        l_type         varchar2(100);
    begin
        pc_log.log_error('insert_ar_invoice', 'ENTRP_ID ' || p_entrp_id);
        pc_log.log_error('insert_ar_invoice', 'P_START_DATE ' || p_start_date);
        pc_log.log_error('insert_ar_invoice', 'P_END_DATE ' || p_end_date);
        pc_log.log_error('insert_ar_invoice', 'P_PRODUCT_TYPE ' || p_product_type);

    -- Added By Swamy for 11758 for stacked account for claim invoice, the invoice is not generated as the product type was passed as NULL.
        l_type := upper(pc_benefit_plans.get_entrp_ben_account_type(p_entrp_id));
        if l_type = 'STACKED' then
            for i in (
                select
                    a.product_type
                from
                    invoice_parameters a
                where
                        a.entity_id = p_entrp_id
                    and a.entity_type = 'EMPLOYER'
                    and a.status = 'A'
                    and a.invoice_type = 'CLAIM'
            ) loop
                l_product_type := i.product_type;
            end loop;

            l_product_type := nvl(l_product_type, p_product_type);
        else
            l_product_type := p_product_type;
        end if;

        select
            ar_invoice_seq.nextval
        into l_invoice_id
        from
            dual;

        insert into ar_invoice (
            invoice_id,
            invoice_number,
            invoice_date,
            billing_date,
            invoice_due_date,
            invoice_type,
            invoice_reason,
            invoice_amount,
            pending_amount,
            acc_id,
            acc_num,
            entity_id,
            entity_type,
            invoice_term,
            auto_pay,
            rate_plan_id,
            payment_method,
            batch_number,
            status,
            last_invoiced_date,
            start_date,
            end_date,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            bank_acct_id,
            billing_name,
            billing_attn,
            billing_address,
            billing_city,
            billing_zip,
            billing_state,
            division_code,
            plan_type
        )
            select
                l_invoice_id,
                invoice_number_seq.nextval,
                sysdate     invoice_date,
                sysdate + 1 billing_date,
                sysdate + 1,
                'AUTO',
                p_invoice_reason,
                0,
                0,
                b.acc_id,
                b.acc_num,
                b.entrp_id,
                'EMPLOYER',
                a.payment_term,
                a.autopay,
                c.rate_plan_id,
                a.payment_method,
                p_batch_number,
                'DRAFT',
                a.last_invoiced_date,
                p_start_date,
                p_end_date,
                0,
                sysdate,
                0,
                sysdate,
                a.bank_acct_id,
                billing_name,
                billing_attn,
                billing_address,
                billing_city,
                billing_zip,
                billing_state,
                a.division_code,
                case
                    when p_invoice_reason = 'CLAIM' then
                        nvl(p_product_type, b.account_type)
                    when b.account_type not in ( 'HRA', 'FSA' ) then
                        b.account_type
                    else
                        nvl(a.product_type,
                            decode(
                            pc_benefit_plans.get_entrp_ben_account_type(b.entrp_id),
                            'HRA',
                            'HRA',
                            'Stacked',
                            'HRAFSA',
                            'FSA'
                        ))
                end         product_type
            from
                invoice_parameters a,
                account            b,
                rate_plans         c
            where
                    b.entrp_id = p_entrp_id
                and a.entity_id = b.entrp_id
                and a.entity_type = 'EMPLOYER'
                and c.entity_id = a.entity_id
                and c.rate_plan_id = a.rate_plan_id
                and c.entity_type = a.entity_type
                and c.status = 'A'
                and a.status = 'A'
                and a.invoice_type = p_invoice_reason
                and ( a.product_type is null
                      or a.product_type = l_product_type ) -- Changed from P_PRODUCT_TYPE to l_product_type By Swamy for 11758 --P_PRODUCT_TYPE)
                and nvl(a.division_code, '-1') = nvl(c.division_code, '-1')
                and nvl(c.division_code, '-1') = nvl(p_division_code,
                                                     nvl(c.division_code, '-1'))
          --      AND    B.ACCOUNT_TYPE IN ('HRA','FSA')
                and c.rate_plan_type = 'INVOICE'
                and trunc(c.effective_date) <= p_end_date
                and ( c.effective_end_date is null
                      or c.effective_end_date >= p_end_date );

        if sql%rowcount > 0 then
            x_invoice_id := l_invoice_id;
        end if;
        pc_log.log_error('insert_ar_invoice', 'X_INVOICE_ID ' || x_invoice_id);
    end insert_ar_invoice;
-- Collects the data from Claim Automation tables
    procedure proc_claim_summary (
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_start_date    in date,
        p_end_date      in date,
        p_product_type  in varchar2,
        p_division_code in varchar2 default null
    ) is
    begin
        pc_log.log_error('proc_claim_summary', 'p_division_code ' || p_division_code);
        pc_log.log_error('proc_claim_summary', 'p_invoice_id ' || p_invoice_id);
        pc_log.log_error('proc_claim_summary', 'p_entrp_id ' || p_entrp_id);
        insert into invoice_distribution_summary (
            invoice_id,
            entrp_id,
            invoice_kind,
            invoice_reason,
            pers_id,
            plans,
            rate_code,
            account_type,
            invoice_days,
            start_date,
            end_date,
            entity_id,
            entity_type,
            rate_amount,
            division_code
        )
            select distinct
                p_invoice_id, --invoice_id
                p_entrp_id, --entrp_id
                'CLAIM', --invoice_kind
                'CLAIM', --invoice_reason
                b.pers_id, --pers_id
                c.service_type, --plans
                c.pay_reason, --rate_code
                a.product_type,
                1,
                p_start_date,
                p_end_date,
                a.claim_id,
                'CLAIMN',
                a.payment_amount,
                b.division_code
            from
                claim_auto_process a,
                person             b,
                claimn             c
            where
                    trunc(a.creation_date) = trunc(sysdate)
                and a.entrp_id = p_entrp_id
                and a.claim_id = c.claim_id
                and a.claim_status in ( 'APPROVED_FOR_CHEQUE' )
                and a.invoice_status = 'NOT_PROCESSED'
                and a.process_status = 'UNRELEASED'
                and c.entrp_id = a.entrp_id
                and c.pers_id = b.pers_id
                and a.entrp_id = b.entrp_id
                and nvl(b.division_code, '-1') = nvl(p_division_code,
                                                     nvl(b.division_code, '-1'))
                and nvl(c.takeover, 'N') = 'N' -- do not invoice for takeoever claim
                and a.product_type = p_product_type;

        if sql%rowcount > 0 then
            update claim_auto_process
            set
                invoice_status = 'PROCESSED',
                invoice_date = sysdate,
                invoice_id = p_invoice_id
            where
                    entrp_id = p_entrp_id
                and product_type = p_product_type
                and claim_status in ( 'APPROVED_FOR_CHEQUE' )
                and invoice_status = 'NOT_PROCESSED'
                and process_status = 'UNRELEASED'
                and claim_id in (
                    select
                        claim_id
                    from
                        claimn a, person b
                    where
                            a.claim_id = claim_auto_process.claim_id
                        and a.pers_id = b.pers_id
                        and nvl(b.division_code, '-1') = nvl(p_division_code,
                                                             nvl(b.division_code, '-1'))
                )
                and exists (
                    select
                        *
                    from
                        invoice_distribution_summary
                    where
                            entity_id = claim_auto_process.claim_id
                        and entity_type = 'CLAIMN'
                        and invoice_kind = 'CLAIM'
                        and entrp_id = claim_auto_process.entrp_id
                        and invoice_id = p_invoice_id
                );

        end if;

    end proc_claim_summary;

-- not used so far
    procedure run_claim_invoice is

        l_error_status  varchar2(3200);
        l_error_message varchar2(3200);
        l_from_date     date;
        l_to_date       date;
        l_entrp_id      number;
    begin
        for x in (
            select
                sysdate - 7 + rownum                 inv_date,
                to_char(sysdate - 7 + rownum, 'D')   day_num,
                to_char(sysdate - 7 + rownum, 'DAY') day_text
            from
                all_objects
            where
                rownum < 8
        ) loop
            if to_char(sysdate, 'D') in ( '1', '2', '7' ) then
                if x.day_num = '5' then
                    l_from_date := trunc(x.inv_date);
                end if;

                if x.day_num = '6' then
                    l_to_date := trunc(x.inv_date);
                end if;

            else
                if x.day_num = '2' then
                    l_from_date := trunc(x.inv_date);
                end if;

                if x.day_num = '4' then
                    l_to_date := trunc(x.inv_date);
                end if;

            end if;
        end loop;
    end run_claim_invoice;
  -- Used in Website
    function get_funding_invoice (
        p_invoice_id in number
    ) return pc_reports_pkg.claim_t
        pipelined
        deterministic
    is
        l_record_t pc_reports_pkg.claim_row;
    begin
        for x in (
            select
                c.acc_num,
                d.first_name,
                d.last_name,
                a.rate_amount                          check_amount,
                d.division_code,
                pc_person.get_division_name(a.pers_id) division_name,
                a.plans                                service_type,
                pc_lookups.get_fsa_plan_type(a.plans)  service_type_meaning
            from
                invoice_distribution_summary a,
                ar_invoice_lines             ail,
                account                      c,
                person                       d
            where
                    a.invoice_id = p_invoice_id
                and c.pers_id = a.pers_id
                and ail.invoice_line_id = a.invoice_line_id
            --AND   AIL.STATUS <> 'VOID'
                and ail.status not in ( 'VOID', 'CANCELLED' )  -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                and c.pers_id = d.pers_id
            order by
                d.last_name asc
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.first_name := x.first_name;
            l_record_t.last_name := x.last_name;
            l_record_t.check_amount := x.check_amount;
            l_record_t.division_code := x.division_code;
            l_record_t.division_name := x.division_name;
            l_record_t.service_type := x.service_type;
            l_record_t.service_type_meaning := x.service_type_meaning;
            l_record_t.name := x.first_name
                               || ' '
                               || x.last_name;
            pipe row ( l_record_t );
        end loop;
    exception
        when others then
            pc_log.log_error('get_claim_invoice', 'SQLERRM' || sqlerrm);
    end get_funding_invoice;
 -- Used in Website
    function get_claim_invoice (
        p_invoice_id in number
    ) return pc_reports_pkg.claim_t
        pipelined
        deterministic
    is
        l_record_t pc_reports_pkg.claim_row;
    begin
        for x in (
            select
                c.acc_num,
                d.first_name,
                d.last_name
                   -- , to_char(a.creation_date,'mm/dd/yyyy') PAY_DATE
                ,
                b.approved_amount,
                b.claim_pending,
                a.rate_amount                                     check_amount,
                b.claim_id,
                b.claim_amount,
                b.claim_id                                        transaction_number,
                decode(ail.rate_code,
                       19,
                       'Direct Deposit',
                       13,
                       'Debit Card Purchase',
                       pc_lookups.get_reason_name(ail.rate_code)) reimbursement_method
                    --, DECODE(B.PAY_REASON, 19 ,'Direct Deposit',13, 'Debit Card Purchase','Check')  REIMBURSEMENT_METHOD
                       ,
                d.division_code,
                pc_person.get_division_name(b.pers_id)            division_name,
                b.pay_reason                                      reason_code,
                b.service_type,
                pc_lookups.get_fsa_plan_type(b.service_type)      service_type_meaning,
                b.denied_amount,
                b.plan_start_date,
                b.plan_end_date,
                to_char(b.plan_start_date, 'MM/DD/YYYY')
                || '-'
                || to_char(b.plan_end_date, 'MM/DD/YYYY')         plan_year
            from
                invoice_distribution_summary a,
                ar_invoice_lines             ail,
                claimn                       b,
                account                      c,
                person                       d
            where
                    a.invoice_id = p_invoice_id
                and a.entity_id = b.claim_id
                and a.entity_type = 'CLAIMN'
                and c.pers_id = a.pers_id
                and ail.invoice_line_id = a.invoice_line_id
            --AND   AIL.STATUS <> 'VOID'
                and ail.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                and c.pers_id = b.pers_id
                and c.pers_id = d.pers_id
        ) loop
            l_record_t.acc_num := x.acc_num;
            l_record_t.first_name := x.first_name;
            l_record_t.last_name := x.last_name;
              --   l_record_t.pay_date                    := x.pay_date;
            l_record_t.approved_amount := x.approved_amount;
            l_record_t.claim_pending := x.claim_pending;
            l_record_t.check_amount := x.check_amount;
            l_record_t.claim_amount := x.claim_amount;
            l_record_t.transaction_number := x.transaction_number;
            l_record_t.reimbursement_method := x.reimbursement_method;
            l_record_t.division_code := x.division_code;
            l_record_t.division_name := x.division_name;
            l_record_t.reason_code := x.reason_code;
            l_record_t.service_type := x.service_type;
            l_record_t.service_type_meaning := x.service_type_meaning;
            l_record_t.denied_amount := x.denied_amount;
            l_record_t.plan_start_date := x.plan_start_date;
            l_record_t.plan_end_date := x.plan_end_date;
            l_record_t.plan_year := x.plan_year;
            l_record_t.substantiated_flag := 'Yes';
            l_record_t.remaining_offset_amt := 0;
            l_record_t.claim_id := x.claim_id;
            l_record_t.name := x.first_name
                               || ' '
                               || x.last_name;
            pipe row ( l_record_t );
        end loop;
    exception
        when others then
            pc_log.log_error('get_claim_invoice', 'SQLERRM' || sqlerrm);
    end get_claim_invoice;
-- Called from APEX when users want to add claims to manual invoice
    procedure save_claim_summary (
        p_invoice_id      in number,
        p_invoice_line_id in number,
        p_reason_code     in number,
        p_claim_id        in number,
        p_amount          in number,
        p_division_code   in varchar2 default null,
        x_return_status   out varchar2,
        x_error_message   out varchar2
    ) is

        l_pers_id         number;
        l_plan_type       varchar2(30);
        l_approved_amount number;
        e_claim exception;
        l_division_code   varchar2(30);
    begin
        x_return_status := 'S';
        for x in (
            select
                pers_id,
                service_type,
                approved_amount
            from
                claimn
            where
                claim_id = p_claim_id
        ) loop
            l_pers_id := x.pers_id;
            l_plan_type := x.service_type;
            l_approved_amount := x.approved_amount;
        end loop;

        for x in (
            select
                division_code,
                rate_plan_id
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
            if
                x.division_code is not null
                and x.division_code <> nvl(
                    pc_person.get_division_code(l_pers_id),
                    '-1'
                )
            then
                x_error_message := 'Cannod add the claim to this invoice as invoice division is different from the person division';
                raise e_claim;
            end if;
        end loop;

        if l_approved_amount < p_amount then
            x_error_message := 'Claim Amount cannot be more than approved amount';
            raise e_claim;
        end if;
        update invoice_distribution_summary
        set
            rate_amount = p_amount
        where
                invoice_line_id = p_invoice_line_id
            and entity_id = p_claim_id
            and entity_type = 'CLAIMN'
            and rate_code = p_reason_code;

        if sql%rowcount = 0 then
            insert into invoice_distribution_summary (
                invoice_id,
                invoice_line_id,
                entrp_id,
                invoice_kind,
                invoice_reason,
                pers_id,
                plans,
                rate_code,
                account_type,
                invoice_days,
                start_date,
                end_date,
                entity_id,
                entity_type,
                rate_amount,
                division_code
            )
                select
                    p_invoice_id, --invoice_id
                    p_invoice_line_id,
                    entity_id, --entrp_id
                    'CLAIM', --invoice_kind
                    'CLAIM', --invoice_reason
                    l_pers_id, --pers_id
                    l_plan_type, --plans
                    p_reason_code, --rate_code
                    pc_lookups.get_meaning(l_plan_type, 'FSA_HRA_PRODUCT_MAP'),
                    1,
                    start_date,
                    end_date,
                    p_claim_id,
                    'CLAIMN',
                    p_amount,
                    p_division_code
                from
                    ar_invoice
                where
                    invoice_id = p_invoice_id;

        end if;

        update_ar_inv_lines(p_invoice_line_id);
    exception
        when e_claim then
            x_return_status := 'E';
        when no_data_found then
            x_error_message := 'Cannot find the claim details ';
            x_return_status := 'E';
        when others then
            x_error_message := 'Error in processing the claim detail';
            x_return_status := 'E';
    end save_claim_summary;

-- Called from APEX when users want to remove the invoice
    procedure delete_claim_summary (
        p_invoice_id      in number,
        p_invoice_line_id in number,
        p_claim_id        in number
    ) is
    begin
        delete from invoice_distribution_summary
        where
                entity_id = p_claim_id
            and entity_type = 'CLAIMN'
            and invoice_id = p_invoice_id
            and invoice_line_id = p_invoice_line_id;

        update_ar_inv_lines(p_invoice_line_id);
    end delete_claim_summary;

    procedure update_ar_inv_lines (
        p_invoice_line_id in number
    ) is
    begin
        for x in (
            select
                sum(rate_amount) amount,
                count(entity_id) no_of_claim
            from
                invoice_distribution_summary
            where
                invoice_line_id = p_invoice_line_id
        ) loop
            update ar_invoice_lines
            set
                quantity = x.no_of_claim,
                unit_rate_cost = x.amount,
                total_line_amount = x.amount
            where
                invoice_line_id = p_invoice_line_id;

        end loop;
    end update_ar_inv_lines;

  -- Called to create skeleton invoice
    procedure create_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_invoice_reason in varchar2,
        x_invoice_id     out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2,
        p_division_code  in varchar2 default null
    ) is
        l_batch_number  number;
        l_error_message varchar2(3200);
        l_invoice_id    number;
    begin
        x_error_status := 'S';
        select
            invoice_batch_seq.nextval
        into l_batch_number
        from
            dual;

        insert_ar_invoice(p_start_date, p_end_date, p_billing_date, p_entrp_id, p_product_type,
                          l_batch_number, p_invoice_reason, l_invoice_id, p_division_code);

        x_invoice_id := l_invoice_id;
    end create_invoice;
  -- When companies sign up for Funding first time they have to create claim to create
  -- funds so they setup in rate plans and collect the funding
  -- called from Apex
    procedure generate_funding_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_invoice_reason in varchar2,
        x_invoice_id     out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2,
        p_division_code  in varchar2 default null
    ) is

        l_batch_number  number;
        l_error_message varchar2(3200);
        l_invoice_id    number;
        l_invoice_type  varchar2(100);
        l_invoice_limit number;
    begin
        select
            invoice_batch_seq.nextval
        into l_batch_number
        from
            dual;

      -- Added by Joshi for 10573. update payment to Wire transfer for invoices > 100K
        l_invoice_limit := pc_lookups.get_meaning('INVOICE_LIMIT', 'WIRE_TRANSFER_LIMIT');
        insert_ar_invoice(p_start_date, p_end_date, p_billing_date, p_entrp_id, p_product_type,
                          l_batch_number, 'FUNDING', l_invoice_id, p_division_code);

        pc_log.log_error('generate_funding_invoice', 'L_INVOICE_ID ' || l_invoice_id);
        process_funding_invoice(
            p_start_date    => p_start_date,
            p_end_date      => p_end_date,
            p_invoice_id    => l_invoice_id,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        pc_log.log_error('generate_funding_invoice', 'x_error_status ' || x_error_status);
        pc_log.log_error('generate_funding_invoice', 'x_error_message ' || x_error_message);
        for x in (
            select
                ar.invoice_id,
                ar.entity_id,
                sum(arl.total_line_amount) invoice_amount,
                ar.rate_plan_id
            from
                ar_invoice       ar,
                ar_invoice_lines arl
            where
                    ar.invoice_id = l_invoice_id
                and ar.invoice_id = arl.invoice_id
                and ar.status = 'DRAFT'
                and arl.status = 'DRAFT'
            group by
                ar.invoice_id,
                ar.entity_id,
                ar.rate_plan_id
        ) loop
            update ar_invoice
            set
                status = 'GENERATED',
                invoice_amount = x.invoice_amount,
                pending_amount = x.invoice_amount
                     -- Added by Joshi for 10573. update payment to Wire transfer for invoices > 100K
                ,
                payment_method =
                    case
                        when x.invoice_amount >= l_invoice_limit then
                            'WIRE_TRANSFER'
                        else
                            payment_method
                    end,
                last_update_date = sysdate,
                last_updated_by = 0
            where
                invoice_id = x.invoice_id;

            update ar_invoice_lines
            set
                status = 'GENERATED',
                last_update_date = sysdate,
                last_updated_by = 0
            where
                invoice_id = x.invoice_id;
                -- set last invoiced date
            update invoice_parameters
            set
                last_invoiced_date = sysdate
            where
                    entity_id = x.entity_id
                and entity_type = 'EMPLOYER'
                and invoice_type = p_invoice_reason
                and rate_plan_id = x.rate_plan_id;

        end loop;

    -- Deleting the invoices that is in draft status
 /*  DELETE FROM AR_INVOICE
     WHERE NOT EXISTS ( SELECT * FROM AR_INVOICE_LINES WHERE INVOICE_ID = AR_INVOICE.INVOICE_ID)
     AND STATUS = 'DRAFT'
     AND TRUNC(CREATION_DATE) = TRUNC(SYSDATE)
     AND invoice_id = L_INVOICE_ID;*/
   --IF SQL%ROWCOUNT = 0 THEN
        x_invoice_id := l_invoice_id;
  -- END IF;
    exception
    --  WHEN INVOICE_EXCEPTION THEN
    --    RAISE_APPLICATION_ERROR('-20001',l_error_message);
    --    rollback;
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            raise_application_error('-20001', x_error_message);
            pc_log.log_error('PC_INVOICE.generate_claim_invoice',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            rollback;
    end generate_funding_invoice;
-- collects the fees data for building funding invoice
    procedure process_funding_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_invoice_id    in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_line_type        varchar2(100);
        l_total_inv_amount number;
        l_quantity         number;
        l_no_of_months     number;
        l_invoice_line_id  number;
    begin
        for x in (
            select
                a.invoice_id,
                b.rate_code,
                b.rate_plan_cost,
                b.rate_basis,
                b.rate_plan_id,
                b.calculation_type,
                a.entity_id,
                c.plan_type,
                a.invoice_date,
                a.last_invoiced_date,
                c.reason_name rate_description,
                a.batch_number
            from
                ar_invoice         a,
                rate_plan_detail   b,
                invoice_parameters d   --FSA Funding
                ,
                pay_reason         c
            where
                    a.invoice_id = p_invoice_id
                and a.rate_plan_id = b.rate_plan_id
                and d.rate_plan_id = b.rate_plan_id
                and d.invoice_param_id = b.invoice_param_id
                and trunc(b.effective_date) <= p_start_date
                and ( b.effective_end_date is null
                      or b.effective_end_date >= p_end_date ) --It will be end dated by pgm not by user
                and a.status = 'DRAFT'
                and d.status = 'A'
                and a.entity_type = 'EMPLOYER'
                and b.rate_code = to_char(c.reason_code)
                and ( d.product_type is null
                      or d.product_type = a.plan_type )   --FSA Funding
                and d.entity_id = a.entity_id
                and d.invoice_type = a.invoice_reason
        )  -- FSA Funding
         loop
            if x.rate_basis = 'FLAT_FEE' then
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => x.invoice_id,
                    p_invoice_line_type => x.rate_basis,
                    p_rate_code         => x.rate_code,
                    p_description       => x.rate_description,
                    p_quantity          => 1,
                    p_no_of_months      => 1,
                    p_rate_cost         => x.rate_plan_cost,
                    p_total_cost        => x.rate_plan_cost,
                    p_batch_number      => x.batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );
                     --Update the Effective end date automatically
                update rate_plan_detail
                set
                    effective_end_date = p_end_date,
                    last_update_date = sysdate
                where
                        rate_code = x.rate_code
                    and one_time_flag = 'Y'
                    and effective_date <= p_start_date
                    and ( effective_end_date is null
                          or effective_end_date >= p_end_date )
                    and rate_plan_id = x.rate_plan_id;

            end if;
        end loop;
    exception
        when others then
            pc_log.log_error('Process_funding_invoice', sqlerrm);
            x_error_message := 'Error in process funding invoice';
            x_error_status := 'E';
    end process_funding_invoice;

  -- Every Payroll we need to collect the funds from groups for the
  -- funding groups
    procedure generate_payroll_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_entrp_id       in number,
        p_product_type   in varchar2,
        p_invoice_reason in varchar2,
        x_invoice_id     out number,
        x_error_status   out varchar2,
        x_error_message  out varchar2,
        p_division_code  in varchar2 default null
    ) is

        l_batch_number  number;
        l_error_message varchar2(3200);
        l_invoice_id    number;
        l_invoice_type  varchar2(100);
        l_invoice_limit number := 0;
    begin
        select
            invoice_batch_seq.nextval
        into l_batch_number
        from
            dual;

     -- Added by Joshi for 10573. update payment to Wire transfer for invoices > 100K
        l_invoice_limit := pc_lookups.get_meaning('INVOICE_LIMIT', 'WIRE_TRANSFER_LIMIT');
        insert_ar_invoice(p_start_date, p_end_date, p_billing_date, p_entrp_id, p_product_type,
                          l_batch_number, 'FUNDING', l_invoice_id, p_division_code);

        dbms_output.put_line('INVOICE_ID ' || l_invoice_id);
        proc_funding_summary(
            p_invoice_id    => l_invoice_id,
            p_entrp_id      => p_entrp_id,
            p_start_date    => p_start_date,
            p_end_date      => p_end_date,
            p_product_type  => p_product_type,
            p_division_code => p_division_code
        );

        dbms_output.put_line('INVOICE_ID ' || l_invoice_id);
        process_payroll_invoice(
            p_start_date    => p_start_date,
            p_end_date      => p_end_date,
            p_invoice_id    => l_invoice_id,
            p_batch_number  => l_batch_number,
            x_error_status  => x_error_status,
            x_error_message => x_error_message
        );

        for x in (
            select
                ar.invoice_id,
                ar.entity_id,
                sum(arl.total_line_amount) invoice_amount,
                ar.rate_plan_id
            from
                ar_invoice       ar,
                ar_invoice_lines arl
            where
                    ar.invoice_id = l_invoice_id
                and ar.invoice_id = arl.invoice_id
                and ar.status = 'DRAFT'
                and arl.status = 'DRAFT'
            group by
                ar.invoice_id,
                ar.entity_id,
                ar.rate_plan_id
        ) loop
            update ar_invoice
            set
                status = 'GENERATED',
                invoice_amount = x.invoice_amount,
                pending_amount = x.invoice_amount,
                last_update_date = sysdate,
                last_updated_by = 0
                          -- Added by Joshi for 10573. update payment to Wire transfer for invoices > 100K
                ,
                payment_method =
                    case
                        when x.invoice_amount >= l_invoice_limit then
                            'WIRE_TRANSFER'
                        else
                            payment_method
                    end,
                bank_acct_id =
                    case
                        when invoice_amount >= l_invoice_limit then
                            null
                        else
                            bank_acct_id
                    end
            where
                invoice_id = x.invoice_id;

            update ar_invoice_lines
            set
                status = 'GENERATED',
                last_update_date = sysdate,
                last_updated_by = 0
            where
                invoice_id = x.invoice_id;

                -- set last invoiced date
            update invoice_parameters
            set
                last_invoiced_date = sysdate
            where
                    entity_id = x.entity_id
                and entity_type = 'EMPLOYER'
                and invoice_type = p_invoice_reason
                and rate_plan_id = x.rate_plan_id;

        end loop;

    -- Deleting the invoices that is in draft status
        delete from ar_invoice
        where
            not exists (
                select
                    *
                from
                    ar_invoice_lines
                where
                    invoice_id = ar_invoice.invoice_id
            )
                and status = 'DRAFT'
                and trunc(creation_date) = trunc(sysdate)
                and invoice_id = l_invoice_id;

    exception
    --  WHEN INVOICE_EXCEPTION THEN
    --    RAISE_APPLICATION_ERROR('-20001',l_error_message);
    --    rollback;
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            raise_application_error('-20001', x_error_message);
            pc_log.log_error('PC_INVOICE.generate_claim_invoice',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            rollback;
    end generate_payroll_invoice;

-- Collect the payroll funding details from the scheduler setup
    procedure proc_funding_summary (
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_start_date    in date,
        p_end_date      in date,
        p_product_type  in varchar2,
        p_division_code in varchar2 default null
    ) is
    begin
        insert into invoice_distribution_summary (
            invoice_id,
            entrp_id,
            invoice_kind,
            invoice_reason,
            pers_id,
            plans,
            rate_code,
            account_type,
            invoice_days,
            start_date,
            end_date,
            entity_id,
            entity_type,
            rate_amount,
            division_code
        )
            select
                p_invoice_id, --invoice_id
                p_entrp_id, --entrp_id
                'FUNDING', --invoice_kind
                'FUNDING', --invoice_reason
                b.pers_id, --pers_id
                a.plan_type, --plans
                case
                    when pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP') = 'FSA' then
                        70
                    else
                        69
                end, --rate_code
                pc_lookups.get_meaning(a.plan_type, 'FSA_HRA_PRODUCT_MAP'),
                1,
                p_start_date,
                p_end_date,
                a.scheduler_detail_id,
                'SCHEDULER_DETAILS',
                nvl(a.payroll_amount, 0),
                b.division_code
            from
                payroll_contribution a,
                account              d,
                person               b
            where
                    a.entrp_id = p_entrp_id
                and a.plan_type is not null
                and a.acc_id = d.acc_id
                and d.pers_id = b.pers_id
                and a.processed_flag is null
                and trunc(a.payroll_date) between p_start_date and p_end_date
                and invoice_id is null
                and ( ( p_division_code is null )
                      or ( b.division_code is not null
                           and b.division_code = p_division_code ) );

        update payroll_contribution
        set
            invoice_id = p_invoice_id,
            processed_flag = 'Y'
        where
                entrp_id = p_entrp_id
            and processed_flag is null
            and invoice_id is null
            and trunc(payroll_date) between p_start_date and p_end_date
            and scheduler_detail_id in (
                select
                    entity_id
                from
                    invoice_distribution_summary
                where
                        invoice_id = p_invoice_id
                    and entity_type = 'SCHEDULER_DETAILS'
            );

    end proc_funding_summary;

-- Build Invoice lines from Aggregate data
    procedure process_payroll_invoice (
        p_start_date    in date,
        p_end_date      in date,
        p_invoice_id    in number,
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        l_invoice_line_id number;
    begin
        for xx in (
            select
                sum(nvl(rate_amount, 0)) amount,
                count(entity_id)         quantity,
                ids.rate_code,
                p.reason_name
                || ' for '
                || ids.plans             reason_name,
                ids.plans
            from
                invoice_distribution_summary ids,
                pay_reason                   p
            where
                    ids.invoice_id = p_invoice_id
                and ids.invoice_kind = 'FUNDING'
                and ids.invoice_reason = 'FUNDING'
                and ids.entity_type = 'SCHEDULER_DETAILS'
                and ids.rate_code = p.reason_code
                and p.reason_type = 'RECEIPT'
            group by
                ids.rate_code,
                p.reason_name,
                ids.plans
        ) loop
            pc_invoice.insert_invoice_line(
                p_invoice_id        => p_invoice_id,
                p_invoice_line_type => 'FUNDING',
                p_rate_code         => xx.rate_code,
                p_description       => xx.reason_name,
                p_quantity          => xx.quantity,
                p_no_of_months      => 1,
                p_rate_cost         => xx.amount,
                p_total_cost        => xx.amount,
                p_batch_number      => p_batch_number,
                x_invoice_line_id   => l_invoice_line_id
            );

            update invoice_distribution_summary
            set
                invoice_line_id = l_invoice_line_id
            where
                    rate_code = xx.rate_code
                and invoice_id = p_invoice_id
                and invoice_kind = 'FUNDING'
                and plans = xx.plans;

        end loop;
    end process_payroll_invoice;

    function get_fee (
        p_invoice_id  in number,
        p_reason_code in number,
        p_start_date  in date,
        p_end_date    in date
    ) return number is
        l_fee number := 0;
    begin
        for x in (
            select
                a.rate_plan_cost
            from
                rate_plan_detail a,
                rate_plans       b,
                ar_invoice       c
            where
                    a.rate_plan_id = b.rate_plan_id
                and a.rate_code = to_char(p_reason_code)
                and b.rate_plan_id = c.rate_plan_id
                and c.invoice_id = p_invoice_id
                and trunc(b.effective_date) <= p_end_date
                and ( b.effective_end_date is null
                      or b.effective_end_date >= p_end_date
                      or b.effective_end_date between p_start_date and p_end_date )
                and trunc(a.effective_date) <= p_end_date
                and ( a.effective_end_date is null
                      or a.effective_end_date >= p_end_date
                      or a.effective_end_date between p_start_date and p_end_date )
        ) loop
            l_fee := nvl(x.rate_plan_cost, 0);
        end loop;

        return l_fee;
    end get_fee;

    function get_outstanding_balance (
        p_entity_id      in number,
        p_entity_type    in varchar2,
        p_invoice_reason in varchar2,
        p_invoice_id     in number
    ) return number is
        l_invoice_amount number := 0;
    begin
        for x in (
            select
                sum(invoice_amount - nvl(void_amount, 0) - nvl(paid_amount, 0)) invoice_amount
            from
                ar_invoice
            where
                    entity_id = p_entity_id
                and status in ( 'PROCESSED', 'PARTIALLY_PAID' )
                and entity_type = p_entity_type
                and invoice_reason = p_invoice_reason
                and invoice_id <> p_invoice_id
                and exists (
                    select
                        *
                    from
                        ar_invoice
                    where
                            invoice_id = p_invoice_id
                        and status <> 'POSTED'
                )
        ) loop
            l_invoice_amount := x.invoice_amount;
        end loop;

        return nvl(l_invoice_amount, 0);
    end get_outstanding_balance;

    procedure run_payroll_invoice (
        p_payroll_date in date,
        p_entrp_id     in number default null
    ) is

        l_invoice_id          number;
        x_error_status        varchar2(1000);
        x_error_message       varchar2(1000);
        l_div_invoicing_count number := 0;
        l_division_tab        varchar2_tbl;
    begin
        for x in (
            select distinct
                entrp_id,
                pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') plan_type,
                min(trunc(payroll_date))                                 payroll_date,
                max(trunc(payroll_date))                                 end_date
            from
                payroll_contribution
            where
                    trunc(creation_date) = p_payroll_date   /*-->= changed on 06/04/2018 to go by creation date for processing same day calendar**/
                and processed_flag is null
                and entrp_id = nvl(p_entrp_id, entrp_id)
            group by
                entrp_id,
                pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP')
        ) loop
            pc_log.log_error('run_payroll_invoice', 'entrp_id ' || x.entrp_id);
            l_division_tab(1) := null;
            begin
                select
                    division_code
                bulk collect
                into l_division_tab
                from
                    rate_plans
                where
                        entity_id = x.entrp_id
                    and division_invoicing = 'Y'
                    and status = 'A';

            exception
                when no_data_found then
                    l_division_tab(1) := null;
            end;

            pc_log.log_error('run_payroll_invoice', 'entrp_id '
                                                    || x.entrp_id
                                                    || 'l_division_tab.count'
                                                    || l_division_tab.count);
            -- IF THE DIVISION INVOICING IS NOT SETUP FOR EMPLOYER WITH DIVISIONS
          -- WE WILL RUN AS IF IT IS NOT SETUP
          -- IF THE # OF DIVISION IS NOT MATCHING WITH # OF INVOICE SETUPS FOR DIVISIONS
          -- WE HAVE TO FIGURE OUT

            if l_division_tab.count = 0 then
                l_division_tab.delete;
                l_division_tab(1) := null;
            end if;

            pc_log.log_error('run_payroll_invoice', 'entrp_id '
                                                    || x.entrp_id
                                                    || 'l_division_tab.count'
                                                    || l_division_tab.count);

            for i in 1..l_division_tab.count loop
                pc_log.log_error('run_payroll_invoice',
                                 'division_code ' || l_division_tab(i));
                pc_invoice.generate_payroll_invoice(
                    p_start_date     => x.payroll_date,
                    p_end_date       => x.end_date,
                    p_billing_date   => sysdate,
                    p_entrp_id       => x.entrp_id,
                    p_product_type   => x.plan_type,
                    p_invoice_reason => 'FUNDING',
                    x_invoice_id     => l_invoice_id,
                    x_error_status   => x_error_status,
                    x_error_message  => x_error_message,
                    p_division_code  => l_division_tab(i)
                );

                pc_log.log_error('run_payroll_invoice', 'invoice_id ' || l_invoice_id);
                pc_log.log_error('run_payroll_invoice', 'x_error_status ' || x_error_status);
                pc_log.log_error('run_payroll_invoice', 'x_error_message ' || x_error_message);
            end loop;

        end loop;

        pc_reports_pkg.write_funding_report_file;
        pc_reports_pkg.write_detail_funding_file;
        pc_reports_pkg.write_funding_exception_file;
        begin
            if file_exists('funding_invoice_report'
                           || to_char(sysdate, 'mmddyyyy')
                           || '.csv',
                           'CLAIM_DIR') = 'TRUE' then
                mail_utility.email_reports('funding_invoice_report'
                                           || to_char(sysdate, 'mmddyyyy')
                                           || '.csv',
                                           'Funding Invoice Summary file ',
                                           'IT-Team@sterlingadministration.com,clientservices@sterlingadministration.com,Sumithra.Bai@sterlingadministration.com'
                                           ,
                                           '/u01/app/oracle/oradata/claim/');
            end if;

            if file_exists('funding_detail_invoice'
                           || to_char(sysdate, 'mmddyyyy')
                           || '.csv',
                           'CLAIM_DIR') = 'TRUE' then
                mail_utility.email_reports('funding_detail_invoice'
                                           || to_char(sysdate, 'mmddyyyy')
                                           || '.csv',
                                           'Funding Invoice Detail file ',
                                           'IT-Team@sterlingadministration.com,clientservices@sterlingadministration.com,Sumithra.Bai@sterlingadministration.com'
                                           ,
                                           '/u01/app/oracle/oradata/claim/');

            end if;

            if file_exists('funding_exception'
                           || to_char(sysdate, 'mmddyyyy')
                           || '.csv',
                           'CLAIM_DIR') = 'TRUE' then
                mail_utility.email_reports('funding_exception'
                                           || to_char(sysdate, 'mmddyyyy')
                                           || '.csv',
                                           'Funding Groups with plans Missing funding option setup ',
                                           'IT-Team@sterlingadministration.com,clientservices@sterlingadministration.com,Sumithra.Bai@sterlingadministration.com'
                                           ,
                                           '/u01/app/oracle/oradata/claim/');
            end if;

        exception
            when others then
                mail_utility.email_reports('funding_invoice_report'
                                           || to_char(sysdate, 'mmddyyyy')
                                           || '.csv',
                                           'Error in generating/emailing the file ',
                                           'IT-Team@sterlingadministration.com',
                                           '/u01/app/oracle/oradata/claim/');

                null;
                pc_log.log_error('run_payroll_invoice', 'sqlerrm ' || sqlerrm);
        end;

    end run_payroll_invoice;

    function getinvoice (
        p_invoice_id in number
    ) return ret_get_invoice_t
        pipelined
        deterministic
    is

        l_record get_invoice_t;
        l_count  simple_integer := 0;
        e_user_exception exception;
        cursor cur_get_invoice_rec is
        select
            paid_amount,
            nvl(
                pc_invoice.get_outstanding_balance(entrp_id, entity_type, invoice_reason, invoice_id),
                0
            ) bal_due,
            nvl(pending_amount, 0) + nvl(
                pc_invoice.get_outstanding_balance(entrp_id, entity_type, invoice_reason, invoice_id),
                0
            ) total_due
        from
            ar_invoice_v
        where
            invoice_id = p_invoice_id;

    begin
        select
            count(*)
        into l_count
        from
            ar_invoice_v
        where
            invoice_id = p_invoice_id;

        if l_count = 0 then
            raise e_user_exception;
        end if;
        for c1 in cur_get_invoice_rec loop
            l_record := c1;
            pipe row ( l_record );
        end loop;

    exception
        when e_user_exception then
            pc_log.log_error('GETINVOICE', 'Invalid invoice Id: ' || p_invoice_id);
            return;
        when others then
            pc_log.log_error('GETINVOICE', sqlerrm);
            return;
    end getinvoice;

    procedure post_refund (
        p_invoice_id    in number,
        p_pay_code      in number,
        p_check_amount  in number,
        p_issue_check   in varchar2,
        p_reason_code   in number,
        p_note          in varchar2,
        p_refund_date   in date,
        p_user_id       in number,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_employer_payment_id number;
        l_invoice_reason      varchar2(100);
        x_invoice_id          number;
        l_bank_acct_id        number;  -- Added by Swamy for Cobrapoint 02/11/2022
        l_entrp_id            number := 0;
        l_refund_invoice_id   number; -- Added by Swamy for Cobrapoint 02/11/2022
        l_claim_amount        number := 0;  -- Added by Swamy for Cobrapoint 02/11/2022

    begin
        x_return_status := 'S';
        pc_log.log_error('post refund begin', 'begin');
        for x in (
            select
                *
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
            l_invoice_reason := x.invoice_reason;

         -- Added as per the vanitha.
       /* IF p_reason_code in (131,132) THEN

             PC_PREMIUM.CREATE_PREMIUM_REFUND(
                                                                    P_INVOICE_ID => P_INVOICE_ID,
                                                                    P_PERS_ID => X.ENTITY_ID,
                                                                    P_BANK_ACCT_ID => X.BANK_ACCT_ID,
                                                                    P_REFUND_AMOUNT => p_check_amount,
                                                                    P_REFUND_REASON => p_note,  --P_REFUND_REASON,
                                                                    P_USER_ID => P_USER_ID,
                                                                    X_RETURN_STATUS => X_RETURN_STATUS,
                                                                    X_ERROR_MESSAGE => X_ERROR_MESSAGE
                                                                  );
        END IF;
  */
            pc_log.log_error('post refund begin', 'begin l_invoice_reason '
                                                  || l_invoice_reason
                                                  || ' p_reason_code :='
                                                  || p_reason_code);
            if l_invoice_reason = 'PREMIUM' then

         -- Added by Swamy for Cobrapoint 02/11/2022
                for n in (
                    select
                        sum(claim_amount) claim_amount
                    from
                        claimn
                    where
                            claim_code = to_char(x.invoice_id)
                        and claim_status in ( 'PENDING_EMPLOYER_FUNDING', 'PAID' )
                        and pers_id = x.entity_id
                ) loop
                    l_claim_amount := n.claim_amount;
                end loop;

                pc_log.log_error('post refund begin', 'begin **1 l_claim_amount ' || l_claim_amount);
        -- check to find if there are multiple refunds done for the same invoice id. if there are multiple refunds, then the refund amount should be less then the claim amount minus total refunded amount.
                if nvl(x.invoice_amount, 0) - nvl(l_claim_amount, 0) < nvl(p_check_amount, 0) then
                    raise_application_error('-20001',
                                            'Employee has already claimed for amount '
                                            || nvl(l_claim_amount, 0)
                                            || ' for the invoice id '
                                            || p_invoice_id);
                end if;

                if p_reason_code = 132 then
                    for j in (
                        select
                            bank_acct_id
                        from
                            user_bank_acct
                        where
                                acc_id = x.acc_id
                            and status = 'A'
                            and nvl(bank_account_usage, 'INVOICE') in ( 'ONLINE', 'INVOICE' )
                    ) loop
                        l_bank_acct_id := j.bank_acct_id;
                    end loop;

                    if nvl(l_bank_acct_id, -1) = -1 then
                        raise_application_error('-20001', 'There is no Bank account defined');
                    end if;

                end if;

       -- Check if the employee premium amount is already paid to the employer.
       -- If data exists in cobra_payment_staging then it should be considered that the premium payment is already paid to the employer.
                pc_premium.flg_premium_paid(
                    p_invoice_id => x.invoice_id,
                    p_entrp_id   => l_entrp_id
                );
                pc_log.log_error('post refund begin', 'begin **2 l_entrp_id ' || l_entrp_id);
                if nvl(l_entrp_id, 0) <> 0 then
                    if p_reason_code in ( 131, 132, 291 ) then --Added 291 by karthe on 03/07/2024 for credit card charge back
                             -- If the premium is already paid to the employer then
                             -- Create an claim, create an invoice to the employer for the refund amount, post the invoice and create an income to the employee and employer deposit to the employer.
                        pc_premium.create_premium_claim_refund(
                            p_invoice_id        => x.invoice_id,
                            p_pers_id           => x.entity_id,
                            p_bank_acct_id      => nvl(x.bank_acct_id, l_bank_acct_id),
                            p_refund_amount     => p_check_amount,
                            p_user_id           => p_user_id,
                            p_entrp_id          => l_entrp_id,
                            p_reason_code       => p_reason_code,
                            p_refund_invoice_id => l_refund_invoice_id   -- swamycobra
                            ,
                            x_return_status     => x_return_status,
                            x_error_message     => x_error_message
                        );

                        pc_log.log_error('PC_INVOICE.post_refund l_invoice_reason 1.51', 'l_new_invoice_id'
                                                                                         || ' l_refund_invoice_id :='
                                                                                         || l_refund_invoice_id);
                        if x_return_status <> 'S' then
                            raise_application_error('-20001', x_error_message);
                        end if;
                    end if;
                else
                  --If the premium is not yet paid to the employer, but premium is paid by the employee and the
                  --amount stays with sterling then,
                  -- create claim and create an income to the employee and employer deposit to the employer.
                 -- IF  p_reason_code IN (131,132) THEN   -- swamycobra
                    if p_reason_code in ( 131, 132, 291 ) then --Added 291 by karthe on 03/07/2024 for credit card charge back
                          --  Refund of premium through ACH
                        if p_reason_code = 132 then
                            for j in (
                                select
                                    bank_acct_id
                                from
                                    user_bank_acct
                                where
                                        acc_id = x.acc_id
                                    and status = 'A'
                                    and nvl(bank_account_usage, 'INVOICE') in ( 'ONLINE', 'INVOICE' )
                            ) loop
                                l_bank_acct_id := j.bank_acct_id;
                            end loop;

                            if nvl(l_bank_acct_id, -1) = -1 then
                                raise_application_error('-20001', 'There is no Bank account defined');
                            end if;

                        end if;

                        pc_premium.create_premium_refund(
                            p_invoice_id    => x.invoice_id,
                            p_pers_id       => x.entity_id,
                            p_bank_acct_id  => nvl(x.bank_acct_id, l_bank_acct_id),
                            p_refund_amount => p_check_amount,
                            p_refund_reason => p_reason_code,
                            p_user_id       => p_user_id,
                            x_return_status => x_return_status,
                            x_error_message => x_error_message
                        );

                        if x_return_status <> 'S' then
                            raise_application_error('-20001', x_error_message);
                        end if;
                    end if;
                end if;
            --IF p_reason_code = 290 THEN
                if p_reason_code in ( 290, 291 ) then --Added 291 by karthe on 03/07/2024 for credit card charge back
                    pc_invoice.post_cc_refund(
                        p_invoice_id    => x.invoice_id,
                        p_refund_amount => p_check_amount,
                        p_note          => p_note,
                        p_user_id       => p_user_id,
                        x_error_message => x_error_message,
                        x_error_status  => x_return_status
                    );
                end if;

                if p_reason_code in ( 9, 19, 20 ) then
                    insert into income (
                        change_num,
                        acc_id,
                        fee_date,
                        fee_code,
                        amount,
                        pay_code,
                        cc_number,
                        note,
                        amount_add,
                        ee_fee_amount,
                        list_bill,
                        transaction_type,
                        due_date,
                        postmark_date
                    )
                        select
                            change_seq.nextval,
                            i.acc_id,
                            sysdate,
                            p_reason_code,
                            0,
                            i.pay_code,
                            'Returned ' || x.invoice_id,
                            'Premium returned on '
                            || sysdate
                            || 'for premium invoice '
                            || x.invoice_id
                            || 'for due date'
                            || i.due_date,
                            - decode(
                                nvl(p_check_amount, 0),
                                0,
                                i.amount_add,
                                p_check_amount
                            )   -- commented and added by Swamy for Cobrapoint bug fixing -nvl(p_check_amount,0)
                            ,
                            case
                                when p_reason_code in ( 9, 19, 20 ) then
                                    - nvl(i.ee_fee_amount, 0)
                                else
                                    0
                            end,
                            x.invoice_id,
                            'I',
                            x.start_date,
                            p_refund_date
                        from
                            income  i,
                            account a
                        where
                                i.list_bill = x.invoice_id
                            and i.acc_id = a.acc_id
                            and a.pers_id = x.entity_id
                            and a.account_type = 'COBRA'
                            and i.fee_code <> 19;       -- Added by Swamy for Cobrapoint bug fixing

                    update ar_invoice
                    set
                        last_update_date = sysdate,
                        last_updated_by = p_user_id,
                        paid_amount = 0,
                        pending_amount = 0,
                        status = 'RETURNED'
                    where
                            invoice_id = x.invoice_id
                        and status = 'POSTED';

                    update ar_invoice_lines
                    set
                        last_update_date = sysdate,
                        last_updated_by = p_user_id,
                        status = 'RETURNED'
                    where
                            invoice_id = x.invoice_id
                        and status = 'POSTED';

                    pc_invoice.process_cobra_premium(
                        p_start_date    => trunc(x.start_date, 'MM'),
                        p_end_date      => x.end_date,
                        p_billing_date  => sysdate,
                        p_due_date      => x.start_date,
                        p_product_type  => 'COBRA',
                        p_pers_id       => x.entity_id,
                        p_batch_number  => x.batch_number,
                        x_invoice_id    => x_invoice_id,
                        x_error_status  => x_return_status,
                        x_error_message => x_error_message
                    );

                    if x_return_status <> 'S' then
                        raise_application_error('-20001', x_error_message);
                    end if;
                end if;

            else
                insert into employer_payments (
                    employer_payment_id,
                    entrp_id,
                    check_amount,
                    creation_date,
                    created_by,
                    last_update_date,
                    last_updated_by,
                    check_date,
                    reason_code,
                    transaction_date,
                    plan_type,
                    pay_code,
                    invoice_id,
                    note,
                    memo
                ) values ( employer_payments_seq.nextval,
                           x.entity_id,
                           p_check_amount,
                           sysdate,
                           p_user_id,
                           sysdate,
                           p_user_id,
                           p_refund_date
			                  --  ,CASE WHEN X.INVOICE_REASON = 'FEE' THEN 23 ELSE 25 END commented by Joshi for 12255 and added below,
                           ,
                           case
                               when x.invoice_reason = 'FEE'
                                    and p_pay_code in ( 290, 291 ) then
                                   p_pay_code
                               when x.invoice_reason = 'FEE'
                                    and p_pay_code not in ( 290, 291 ) then
                                   23
                               else
                                   25
                           end,
                           p_refund_date,
                           x.plan_type,
                           p_pay_code,
                           x.invoice_id,
                           p_note,
                           p_note ) returning employer_payment_id into l_employer_payment_id;

                if
                    p_pay_code = 1
                    and p_issue_check = 'Y'
                then
                    pc_claim.process_emp_refund(
                        p_entrp_id            => x.entity_id,
                        p_pay_code            => p_pay_code,
                        p_refund_amount       => p_check_amount,
                        p_emp_payment_id      => l_employer_payment_id,
                        p_substantiate_reason => null      -- Added by Swamy for Ticket#5692(Impact Changes)
                        ,
                        x_return_status       => x_return_status,
                        x_error_message       => x_error_message
                    );

                    if p_refund_date > sysdate then
                        update checks
                        set
                            check_date = p_refund_date
                        where
                            check_number = (
                                select
                                    check_number
                                from
                                    employer_payments
                                where
                                    employer_payment_id = l_employer_payment_id
                            );

                    end if;

                end if;

            end if;

        end loop;

        if x_return_status <> 'S' then
            rollback;
        else
            if
                p_invoice_id is not null
                and l_invoice_reason <> 'PREMIUM'
            then
                for x in (
                    select
                        a.invoice_id,
                        sum(nvl(b.check_amount, 0)) check_amount
                    from
                        ar_invoice        a,
                        employer_payments b
                    where
                            a.invoice_id = b.invoice_id
                        and a.invoice_id = p_invoice_id
                        and a.invoice_reason <> 'PREMIUM'
                        and b.reason_code in ( 23, 25, 290, 291 ) -- Added 290,291 by Joshi for 12255
                    group by
                        a.invoice_id
                ) loop
                    update ar_invoice
                    set
                        refund_amount = nvl(x.check_amount, 0)
                    where
                        invoice_id = x.invoice_id;

                end loop;

                update ar_invoice
                set
                    pending_amount =
                        case
                            when invoice_amount = nvl(paid_amount, 0) then
                                0
                            when invoice_amount < nvl(paid_amount, 0) then
                                invoice_amount + nvl(refund_amount, 0) - ( ( nvl(void_amount, 0) + nvl(paid_amount, 0) ) )
                            else
                                invoice_amount - ( ( nvl(void_amount, 0) + nvl(paid_amount, 0) ) )
                        end
                where
                        invoice_id = p_invoice_id
                    and invoice_reason <> 'PREMIUM';

            end if;
        end if;

    end post_refund;

    procedure retry_ach (
        p_invoice_id in number,
        p_user_id    in number
    ) is

        l_return_status varchar2(3200);
        l_error_message varchar2(3200);
        l_count         number := 0;
        l_plan_type     varchar2(255);
    begin
        for x in (
            select
                a.batch_number,
                a.auto_pay,
                a.bank_acct_id,
                a.payment_method,
                a.pending_amount,
                a.acc_id,
                a.invoice_id,
                a.plan_type,
                b.account_type,
                a.invoice_reason
                  -- ,  add_business_days(1,sysdate)  approval_date
                   /* changed transaction date logic as per ticket 11296.Joshi */,
                case
                    when a.invoice_reason = 'FEE' then
                        add_business_days(3, sysdate)
                    when b.account_type in ( 'HRA', 'FSA' )
                         and a.invoice_reason = 'CLAIM' then
                        sysdate + 1
                      -- Added by Jaggi. for COBRA Premium. if invoice is paid after 5pm. set transacton_date to 2 days from current day.
                    when b.account_type in ( 'COBRA' )
                         and a.invoice_reason = 'PREMIUM'
                         and to_number(to_char(current_timestamp, 'hh24')) <= to_number(to_char(trunc(current_timestamp) + 17 / 24,
                                                                                                'hh24')) then
                        add_business_days(1, sysdate)
                    when b.account_type in ( 'COBRA' )
                         and a.invoice_reason = 'PREMIUM'
                         and to_number(to_char(current_timestamp, 'hh24')) > to_number(to_char(trunc(current_timestamp) + 17 / 24,
                                                                                               'hh24')) then
                        add_business_days(2, sysdate)
                    else
                        add_business_days(1, sysdate)
                end approval_date
            from
                ar_invoice a,
                account    b
            where
                    a.invoice_id = p_invoice_id
                and a.acc_id = b.acc_id
        ) loop
            if
                x.bank_acct_id is not null
                and x.payment_method = 'DIRECT_DEPOSIT'
            then
                apply_invoice_payment(
                    p_batch_number       => x.batch_number,
                    p_transaction_number => null,
                    p_transaction_date   => x.approval_date --NVL(X.INVOICE_DUE_DATE-1,SYSDATE+1)
                    ,
                    p_payment_amount     => x.pending_amount,
                    p_acc_id             => x.acc_id,
                    p_invoice_id         => x.invoice_id,
                    p_note               => 'Invoice payment request by auto pay request ',
                    p_bank_account       => x.bank_acct_id,
                    p_user_id            => p_user_id,
                    p_pay_method         => 'DIRECT_DEPOSIT',
                    p_plan_type          => x.plan_type,
                    p_invoice_reason     => x.invoice_reason,
                    x_return_status      => l_return_status,
                    x_error_message      => l_error_message
                );

                if l_return_status <> 'S' then
                    raise_application_error('-20001', l_error_message);
                end if;
            end if;

            if
                x.account_type = 'COBRA'
                and x.invoice_reason = 'PREMIUM'
            then  --Invoice_Reason added by rprabu on 26/05/2022

                update ar_invoice
                set
                    status = 'IN_PROCESS',
                    last_update_date = sysdate
                where
                    invoice_id = p_invoice_id;

                update ar_invoice_lines
                set
                    status = 'IN_PROCESS',
                    last_update_date = sysdate
                where
                    invoice_id = p_invoice_id;

            end if;

        end loop;
    end retry_ach;

    function get_tax (
        p_rate_plan_id in number
    ) return number is
        l_tax number := 0;
    begin
        for x in (
            select
                rate_plan_cost
            from
                rate_plan_detail
            where
                    rate_plan_id = p_rate_plan_id
                and nvl(effective_end_date, sysdate) >= sysdate
                and rate_code = 85
        ) loop
            l_tax := nvl(x.rate_plan_cost, 0);
        end loop;

        return l_tax;
    end get_tax;

    procedure apply_tax (
        p_batch_number in number
    ) is
        l_invoice_line_id number;
        l_inv_line_count  number := 0;
    begin

                 -- Applying Tax
        for x in (
            select
                a.invoice_id,
                a.rate_plan_id,
                a.status,
                sum(arl.total_line_amount) invoice_amount
            from
                ar_invoice       a,
                ar_invoice_lines arl
            where
                    a.batch_number = p_batch_number
                and arl.invoice_line_type <> 'TAX'
                and a.invoice_id = arl.invoice_id
                     -- and    ARL.STATUS <> 'VOID'
                and arl.status not in ( 'VOID', 'CANCELLED' )  -- commented above and added line for #11077  Joshi(04/26/2022')
                and pc_invoice.get_tax(a.rate_plan_id) > 0
            group by
                a.invoice_id,
                a.rate_plan_id,
                a.status
            having
                sum(arl.total_line_amount) > 0
        ) loop
            select
                count(*)
            into l_inv_line_count
            from
                ar_invoice       a,
                ar_invoice_lines arl
            where
                    a.invoice_id = x.invoice_id
                and arl.invoice_line_type = 'TAX'
                and a.invoice_id = arl.invoice_id
                and arl.status <> 'VOID';

            if l_inv_line_count > 0 then
                update ar_invoice_lines
                set
                    unit_rate_cost = round(
                        get_tax(x.rate_plan_id),
                        2
                    ),
                    total_line_amount = round(x.invoice_amount * get_tax(x.rate_plan_id),
                                              2)
                where
                        invoice_id = x.invoice_id
                    and invoice_line_type = 'TAX';

            else
                if get_tax(x.rate_plan_id) > 0 then
                    pc_invoice.insert_invoice_line(
                        p_invoice_id        => x.invoice_id,
                        p_invoice_line_type => 'TAX',
                        p_rate_code         => '85',
                        p_description       => 'Tax',
                        p_quantity          => 1,
                        p_no_of_months      => 1,
                        p_rate_cost         => round(
                            get_tax(x.rate_plan_id),
                            2
                        ),
                        p_total_cost        => round(x.invoice_amount * get_tax(x.rate_plan_id),
                                              2),
                        p_batch_number      => p_batch_number,
                        x_invoice_line_id   => l_invoice_line_id
                    );

                    if x.status = 'GENERATED' then
                        update ar_invoice_lines
                        set
                            status = x.status
                        where
                            invoice_line_id = l_invoice_line_id;

                    end if;

                end if;
            end if;

        end loop;
    end apply_tax;
   -- 03/11/2017:Vanitha:Invoice notification enhancement

    procedure insert_inv_notif (
        p_invoice_id      in number,
        p_invoice_age     in number,
        p_notif_type      in varchar2,
        p_email           in varchar2,
        p_notification_id in number,
        p_template_name   in varchar2
    ) is
    begin
        insert into ar_invoice_notifications (
            invoice_notif_id,
            invoice_id,
            age_of_invoice,
            notification_type,
            mailed_to,
            creation_date,
            notification_id,
            template_name
        ) values ( ar_invoice_notif_seq.nextval,
                   p_invoice_id,
                   p_invoice_age,
                   p_notif_type,
                   substr(p_email, 1, 4000),
                   sysdate,
                   p_notification_id,
                   p_template_name );

    end insert_inv_notif;

    procedure update_result_sent (
        p_invoice_notify_id in number,
        p_notification_id   in number
    ) is
    begin
        update ar_invoice_notifications
        set
            mailed_date = sysdate
        where
            invoice_notif_id = p_invoice_notify_id;

        update email_notifications
        set
            mail_status = 'SENT',
            last_update_date = sysdate
        where
            notification_id = p_notification_id;

    end update_result_sent;
  -- Invoice notification enhancement

  -- 6322: Added by Joshi for paying invoice online.
    procedure pay_invoice_online (
        p_invoice_id       number,
        p_entrp_id         in number,
        p_entity_id        in number,
        p_entity_type      in varchar2,
        p_bank_acct_id     in number,
        p_bank_acct_type   in varchar2,
        p_bank_routing_num in varchar2,
        p_bank_acct_num    in varchar2,
        p_bank_name        in varchar2,
        p_auto_pay         in varchar2,
        p_account_usage    in varchar2,
        p_division_code    in varchar2,
        p_user_id          in number,
        p_business_name    in varchar2  -- Added by Swamy for Ticket#12534
        ,
        x_bank_acct_id     out number   -- Added by Swamy for Ticket#12309
        ,
        x_return_status    out varchar2,
        x_error_message    out varchar2
    ) is

        setup_error exception;
        l_bank_acct_id          number;
        l_bank_exist            number;
        l_bank_usage_type       varchar2(50);
        l_error_status          varchar2(10);
        l_error_message         varchar2(1000);
        l_acc_id                number;
        l_inactive_bank_exist   varchar2(1);
        l_exist_bank_acct_id    number;
        l_duplicate_bank_exists varchar2(1) := 'N';
        l_plan_start_date       date;
        l_plan_end_date         date;
    begin
        x_return_status := 'S';
        pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE begin P_BANK_ACCT_ID: ', p_bank_acct_id
                                                                                 || ' P_AUTO_PAY :='
                                                                                 || ' P_ACCOUNT_USAGE :='
                                                                                 || p_account_usage
                                                                                 || ' P_ENTITY_ID :='
                                                                                 || p_entity_id);

        l_bank_acct_id := p_bank_acct_id;
        l_acc_id := pc_person.acc_id(p_entity_id);
        if
            p_entity_type = 'PERSON'
            and nvl(l_bank_acct_id, 0) = 0
        then  -- And cond. swamy 12662 

          --  Added by Swamy for Ticket#12058
            l_duplicate_bank_exists := pc_user_bank_acct.check_duplicate_bank_account(
                p_routing_number    => p_bank_routing_num,
                p_bank_acct_num     => p_bank_acct_num,
                p_bank_acct_id      => null,
                p_bank_name         => p_bank_name,
                p_bank_account_type => p_bank_acct_type,
                p_acc_id            => l_acc_id,
                p_ssn               => null,
                p_user_id           => p_user_id     -- Added by Swamy for Ticket#12309
            );

            if l_duplicate_bank_exists = 'Y' then
                x_error_message := 'The bank details already exist in our system. Please enter different bank details to procced.';
                raise setup_error;
            end if;
        end if;

-- IF P_BANK_ACCT_ID IS NULL AND P_AUTO_PAY = 'Y' THEN
-- commented above and Added below by Joshi for  9142. Auto='N' for Brokers
        if
            p_auto_pay = 'Y'
            and p_entity_type in ( 'PERSON', 'ACCOUNT' )
        then

      -- 7049. For accounts other than HRA and FSA, bank should be created with ONLIE Usage type
      -- so that it shows up in the BANK Detaill screen.

    /* commented and added below by Jaggi #11700

       SELECT COUNT(*) INTO L_BANK_EXIST
          FROM INVOICE_PARAMETERS
          WHERE ENTITY_TYPE IN ('PERSON', 'EMPLOYER')
              AND ENTITY_ID = DECODE (P_ENTITY_TYPE , 'PERSON',P_ENTITY_ID,P_ENTRP_ID)
              AND PAYMENT_METHOD = 'DIRECT_DEPOSIT'
              AND AUTOPAY = 'Y'
              AND BANK_ACCT_ID IS NOT NULL
              AND INVOICE_TYPE = P_ACCOUNT_USAGE
              AND ( P_DIVISION_CODE is null or ( P_DIVISION_CODE is not null and DIVISION_CODE = P_DIVISION_CODE))
              AND STATUS = 'A' ; */

            --  commented above and added below by Jaggi #11700
            l_exist_bank_acct_id := null;
            for k in (
                select
                    bank_acct_id
                from
                    invoice_parameters
                where
                    entity_type in ( 'PERSON', 'EMPLOYER' )
                    and entity_id = decode(p_entity_type, 'PERSON', p_entity_id, p_entrp_id)
                    and payment_method = 'DIRECT_DEPOSIT'
                    and autopay = 'Y'
                    and bank_acct_id is not null
                    and invoice_type = p_account_usage
                    and ( p_division_code is null
                          or ( p_division_code is not null
                               and division_code = p_division_code ) )
                    and status = 'A'
            ) loop
                if k.bank_acct_id is not null then
                    l_exist_bank_acct_id := k.bank_acct_id;
                    pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE l_exist_bank_acct_id: ', l_exist_bank_acct_id);
                end if;
            end loop;

            pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE **1 l_exist_bank_acct_id: ', l_exist_bank_acct_id);
            if l_bank_acct_id is null then
                for j in (
                    select
                        bank_acct_id
                    from
                        bank_accounts
                    where
                            bank_routing_num = lpad(p_bank_routing_num, 9, 0)
                        and bank_acct_num = p_bank_acct_num
                        --AND LOWER(bank_name) = LOWER(LTRIM(RTRIM(p_bank_name))) -- commented for Ticket#12662 -- Added by swamy for ticket#11800
                        and status = 'A'
                        and entity_id = p_entity_id
                        and bank_account_usage = case
                                                     when p_entity_type = 'PERSON' then
                                                         'ONLINE'
                                                     else
                                                         'INVOICE'
                                                 end
                        and entity_type = case
                                              when p_entity_type = 'PERSON' then
                                                  'ACCOUNT'
                                              else
                                                  p_entity_type
                                          end
                ) loop
                    if j.bank_acct_id is not null then
                        l_bank_acct_id := j.bank_acct_id;
                        pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE l_bank_acct_id: ', l_bank_acct_id);
                    end if;
                end loop;
            end if;

            pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE **2 l_bank_acct_id: ', l_bank_acct_id);
            if
                l_exist_bank_acct_id is not null
                and nvl(l_bank_acct_id, 0) <> nvl(l_exist_bank_acct_id, 0)
            then -- added by jaggi #11700
--        IF NVL(l_bank_acct_id,0) <> NVL(l_exist_bank_acct_id,0) THEN -- added by jaggi #11700
                x_return_status := 'E';
                x_error_message := 'Adding a different bank account to pay for the same account usage type is not allowed. If you wish to use a new bank account,' || 'please remove the previous one by navigating to Add/Update Bank Account page to proceed with the removal.'
                ;
                raise setup_error;
            end if;

        end if;

        pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE **3 P_BANK_ACCT_ID: ', p_bank_acct_id
                                                                               || ' P_ENTITY_TYPE :='
                                                                               || p_entity_type);
        if nvl(p_bank_acct_id, 0) = 0 then

         -- Added below by Joshi for  9142
            if p_entity_type in ( 'PERSON', 'ACCOUNT' ) then
                if p_entity_type = 'ACCOUNT' then
                    l_bank_usage_type := 'INVOICE';
                else
                    l_bank_usage_type := 'ONLINE';
                end if;
            else
                l_bank_usage_type := 'INVOICE';
            end if;

            pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE **4 l_bank_usage_type: ', l_bank_usage_type
                                                                                      || ' P_ENTITY_TYPE :='
                                                                                      || p_entity_type);
            if p_entity_type not in ( 'PERSON' ) then   -- Swamy 12662 Below validation is already done before going to giact.
        -- Added by Joshi for 10573
                l_inactive_bank_exist := pc_user_bank_acct.validate_bank_info(
                    p_entity_id       => p_entity_id,
                    p_entity_type     => p_entity_type,
                    p_routing_number  => p_bank_routing_num,
                    p_bank_acct_num   => p_bank_acct_num,
                    p_bank_name       => p_bank_name,
                    p_bank_acct_id    => null,
                    p_bank_acct_usage => l_bank_usage_type  -- Added by Swamy for Ticket#12309
                );

                pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE **5 l_inactive_bank_exist: ', l_inactive_bank_exist
                                                                                              || ' P_ENTITY_TYPE :='
                                                                                              || p_entity_type);
                if l_inactive_bank_exist = 'I' then
                    x_error_message := 'Your bank details cannot be processed since your input Bank details already exist in our system with INACTIVE Status. Please contact Customer Support team or Add new bank details'
                    ;
                    raise setup_error;
                end if;
         -- code ends here Joshi for 10573
            end if;

        -- added by Jaggi #11452
            l_bank_acct_id := null;
            for j in (
                select
                    bank_acct_id
                from
                    bank_accounts
                where
                        bank_routing_num = lpad(p_bank_routing_num, 9, 0)
                    and bank_acct_num = p_bank_acct_num
                            -- AND LOWER(bank_name)  = LOWER(LTRIM(RTRIM(p_bank_name)))   -- commented for Ticket#12662 -- Added by swamy for ticket#11800
                    and status = 'A'
                    and entity_id = p_entity_id
                    and bank_account_usage = l_bank_usage_type
                    and entity_type = case
                                          when p_entity_type = 'PERSON' then
                                              'ACCOUNT'
                                          else
                                              p_entity_type
                                      end
            ) loop
                if j.bank_acct_id is not null then
                    l_bank_acct_id := j.bank_acct_id;
                    pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE l_bank_acct_id: ', l_bank_acct_id);
                end if;
            end loop;

            pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE **6 l_bank_acct_id: ', l_bank_acct_id
                                                                                   || ' P_ENTITY_TYPE :='
                                                                                   || p_entity_type);
            if l_bank_acct_id is null then
           -- Added By Joshi for 9142
                pc_user_bank_acct.insert_bank_account(
                    p_entity_id          =>
                                 case
                                     when p_entity_type = 'PERSON' then
                                         l_acc_id
                                     else
                                         p_entity_id
                                 end,
                    p_entity_type        =>
                                   case
                                       when p_entity_type = 'PERSON' then
                                           'ACCOUNT'
                                       else
                                           p_entity_type
                                   end,
                    p_display_name       => ltrim(rtrim(p_bank_name)),
                    p_bank_acct_type     => p_bank_acct_type,
                    p_bank_routing_num   => lpad(p_bank_routing_num, 9, 0),
                    p_bank_acct_num      => p_bank_acct_num,
                    p_bank_name          => ltrim(rtrim(p_bank_name)),
                    p_bank_account_usage => l_bank_usage_type,
                    p_user_id            => p_user_id,
                    x_bank_acct_id       => l_bank_acct_id,
                    x_return_status      => l_error_status,
                    x_error_message      => l_error_message
                );
            end if;

        end if;

        pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE **7 l_bank_acct_id: ', l_bank_acct_id
                                                                               || ' P_AUTO_PAY :='
                                                                               || p_auto_pay);
        if l_bank_acct_id is not null then
            -- Updating added by Swamy for Ticket#12534
            update bank_accounts
            set
                business_name = p_business_name
            where
                    bank_acct_id = l_bank_acct_id
                and entity_id = p_entity_id
                and entity_type = p_entity_type;

                 -- set the autopay for invoice
            if p_auto_pay = 'Y' then
                update invoice_parameters
                set
                    payment_method = 'DIRECT_DEPOSIT',
                    autopay = 'Y',
                    bank_acct_id = l_bank_acct_id,
                    last_update_date = sysdate,
                    last_updated_by = p_user_id
                where
                        entity_type = decode(p_entity_type, 'PERSON', 'PERSON', 'EMPLOYER')
                    and entity_id = decode(p_entity_type, 'PERSON', p_entity_id, p_entrp_id)
                    and invoice_type = p_account_usage
                    and ( p_division_code is null
                          or ( p_division_code is not null
                               and division_code = p_division_code ) )
                    and status = 'A';

                     -- Added by Joshi for 11801
                if
                    pc_invoice.is_monthly_invoice(p_invoice_id) = 'Y'
                    and p_entity_type <> 'PERSON'
                then

                        /* commented code for 12091 by Joshi
                        UPDATE monthly_invoice_payment_detail
                                SET  bank_acct_id = l_bank_acct_id 
                                       , payment_method =  'DIRECT_DEPOSIT'
                                       , note =  nvl( note,  ' ' ) ||  to_char(sysdate, 'mm/dd/yyyy') || ' : Bank account is updated from Pay invoice ' || decode(status, 'I' , ' :Changed status from inactive to Active', ' ')

                                       , status = 'A'
                         WHERE entrp_id =  p_entrp_id
                             AND sysdate  BETWEEN plan_start_date AND plan_end_date ;
                         */
                       -- added by joshi for 12091
                    for m in (
                        select
                            *
                        from
                            monthly_invoice_payment_detail mio
                        where
                                mio.entrp_id = p_entrp_id
                            and sysdate between mio.plan_start_date and mio.plan_end_date
                            and mio.monthly_payment_seq_no = (
                                select
                                    max(mii.monthly_payment_seq_no)
                                from
                                    monthly_invoice_payment_detail mii
                                where
                                        mii.entrp_id = mio.entrp_id
                                    and mii.plan_start_date = mio.plan_start_date
                                    and mii.plan_end_date = mio.plan_end_date
                            )
                    ) loop
                        if
                            m.status = 'A'
                            and nvl(m.bank_acct_id, 0) <> l_bank_acct_id
                        then
                            update monthly_invoice_payment_detail
                            set
                                status = 'I',
                                note = nvl(note, ' ')
                                       || to_char(sysdate, 'mm/dd/yyyy')
                                       || ': New Bank account is updated from Pay invoice',
                                last_updated_by = p_user_id,
                                last_update_date = sysdate
                            where
                                    entrp_id = m.entrp_id
                                and monthly_payment_seq_no = m.monthly_payment_seq_no
                                and sysdate between plan_start_date and plan_end_date;

                            populate_monthly_inv_payment_dtl(
                                p_entrp_id        => p_entrp_id,
                                p_source          => m.source,
                                p_payment_method  => 'DIRECT_DEPOSIT',
                                p_bank_acct_id    => l_bank_acct_id,
                                p_charged_to      =>
                                              case
                                                  when p_entity_type = 'ACCOUNT' then
                                                      'EMPLOYER'
                                                  else
                                                      p_entity_type
                                              end,
                                p_plan_start_date => m.plan_start_date,
                                p_plan_end_date   => m.plan_end_date,
                                p_user_id         => p_user_id
                            );

                            pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE  rows_updated : ', sql%rowcount);
                        end if;
                    end loop;

                end if;

            end if;

         -- Update Inovice payment terms.
            update ar_invoice
            set
                payment_method = 'DIRECT_DEPOSIT',
                invoice_term = 'IMMEDIATE',
                auto_pay = p_auto_pay    -- 'Y'
                ,
                bank_acct_id = l_bank_acct_id,
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                note = note
                       || ' Changing the Payment Method to Direct Deposit on '
                       || to_char(sysdate, 'MM/DD/YYYY')
            where
                invoice_id = p_invoice_id;

            pc_log.log_error('PC_INVOICE.PAY_INVOICE_ONLINE  before calling PC_INVOICE.retry_ACH l_bank_acct_id : ', l_bank_acct_id); 
        -- Insert ACH Transaction detail.
            if l_bank_acct_id is not null then
                pc_invoice.retry_ach(p_invoice_id, p_user_id);
            end if;
        end if;

        x_bank_acct_id := l_bank_acct_id;    -- Added by Swamy for Ticket#12309 
	              ---- COBRA Payment confirmation Email from QB Login  RPRABU 30/09/2023 
    --- Commented this code as client wants to send the notification oncce payment got posted status. RPRABU 13/06/2024
   /* IF X_RETURN_STATUS = 'S' and P_ENTITY_TYPE = 'PERSON' Then 
              For I in ( select entity_id From  AR_INVOICE 
                            WHERE INVOICE_ID = P_INVOICE_ID 
                            And plan_type ='COBRA'
                            And Invoice_Reason ='PREMIUM'  
                            and Status = 'IN_PROCESS' 
                            And Entity_type ='PERSON' ) 
      Loop
            PC_COBRA_NOTIFICATIONS.COBRA_CONFIRM_QB_ENROLLMENT(P_ENTITY_ID  ,  p_user_id ) ; 
     End Loop; 
   End If;   */

    exception
        when setup_error then
            x_return_status := 'E';
        --x_error_message :=  x_error_message;
            pc_log.log_error('PAY_INVOICE', sqlerrm);
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PAY_INVOICE', sqlerrm);
    end pay_invoice_online;
-- Code ends here Joshi : 6322

    procedure generate_hsa_monthly_invoice as
        l_error_status  varchar2(3200);
        l_error_message varchar2(3200);
        l_batch_number  number;
    begin

       /*Ticket#7391 .For HSA Invoice, generate invoice shud run at 27th of every month .This has to scheduled as separate cron*/
        pc_invoice.generate_invoice(
            trunc(
                trunc(to_date(sysdate), 'MM'),
                'MM'
            ),
            (trunc(to_date(sysdate), 'MM')) + 27,
            null,
            null,
            'HSA',
            l_error_status,
            l_error_message,
            'MONTHLY',
            null,
            l_batch_number
        );
       -- Added below by Swamy for Ticket#10104
        pc_invoice.generate_invoice(
            trunc(
                trunc(to_date(sysdate), 'MM'),
                'MM'
            ),
            (trunc(to_date(sysdate), 'MM')) + 27,
            null,
            null,
            'LSA',
            l_error_status,
            l_error_message,
            'MONTHLY',
            null,
            l_batch_number
        );

    end generate_hsa_monthly_invoice;

-- Start Added by swamy for sql injection (White hat www Vid: 48289429)
    function get_active_invdetail (
        p_invoice_id in number
    ) return invoice_tbl
        pipelined
        deterministic
    is
        l_record invoice_rec;
    begin
        for x in (
            select
                a.description
                ||
                case
                    when invoice_line_type in ( 'RUNOUT', 'ADJUSTMENT' ) then
                            ' '
                            || pc_lookups.get_meaning(invoice_line_type, 'INVOICE_LINE_TYPE')
                    else
                        ' ' || meaning
                end
                description,
                quantity,
                case
                    when calculation_type = 'PERCENTAGE' then
                        nvl(unit_rate_cost, 0) * 100
                    else
                        unit_rate_cost
                end     unit_rate_cost,
                total_line_amount,
                b.reason_name,
                case
                    when quantity * unit_rate_cost > 0 then
                        round(nvl(total_line_amount, 0) /(decode(quantity, 0, 1, quantity) * unit_rate_cost))
                    else
                        1
                end     no_of_months,
                calculation_type,
                rate_code -- Added by Joshi for 8741.
            from
                ar_invoice_lines a,
                pay_reason       b,
                lookups          l
            where
                    invoice_id = p_invoice_id
                and a.status not in ( 'VOID', 'CANCELLED' )
                and a.invoice_line_type = l.lookup_code
                and l.lookup_name = 'INVOICE_LINE_TYPE'
                and nvl(invoice_line_type, '-1') not in ( 'TAX', 'RUNOUT', 'ACTIVE_ADJUSTMENT', 'ADJUSTMENT', 'CLAIM' )
                and a.rate_code = to_char(b.reason_code)
        ) loop
            l_record.description := x.description;
            l_record.quantity := x.quantity;
            l_record.unit_rate_cost := x.unit_rate_cost;
            l_record.total_line_amount := x.total_line_amount;
            l_record.reason_name := x.reason_name;
            if x.calculation_type = 'PERCENTAGE' then
                l_record.no_of_months := 1;
            else
                l_record.no_of_months := x.no_of_months;
            end if;

            l_record.calculation_type := x.calculation_type;
            l_record.rate_code := x.rate_code; -- Added by Joshi for 8741

            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_active_invdetail;

    function get_runout_invdetail (
        p_invoice_id in number
    ) return invoice_tbl
        pipelined
        deterministic
    is
        l_record invoice_rec;
    begin
        for x in (
            select
                a.description
                ||
                case
                    when invoice_line_type in ( 'RUNOUT', 'ADJUSTMENT' ) then
                            ' '
                            || pc_lookups.get_meaning(invoice_line_type, 'INVOICE_LINE_TYPE')
                    else
                        ''
                end
                description,
                quantity,
                unit_rate_cost,
                nvl(total_line_amount, 0) total_line_amount,
                case
                    when quantity * unit_rate_cost > 0 then
                        round(nvl(total_line_amount, 0) /(decode(quantity, 0, 1, quantity) * unit_rate_cost))
                    else
                        1
                end                       no_of_months
            from
                ar_invoice_lines a,
                pay_reason       b
            where
                    invoice_id = p_invoice_id
                and nvl(invoice_line_type, '-1') = 'RUNOUT'
                and a.rate_code = to_char(b.reason_code)
                and a.status <> 'VOID'
        ) loop
            l_record.description := x.description;
            l_record.quantity := x.quantity;
            l_record.unit_rate_cost := x.unit_rate_cost;
            l_record.total_line_amount := x.total_line_amount;
            l_record.no_of_months := x.no_of_months;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_runout_invdetail;

    function get_adj_invdetail (
        p_invoice_id in number
    ) return invoice_tbl
        pipelined
        deterministic
    is
        l_record invoice_rec;
    begin
        for x in (
            select
                a.description
                || ' '
                || l.meaning              description,
                quantity,
                unit_rate_cost,
                nvl(total_line_amount, 0) total_line_amount,
                case
                    when quantity * unit_rate_cost > 0 then
                        round(nvl(total_line_amount, 0) /(decode(quantity, 0, 1, quantity) * unit_rate_cost))
                    else
                        1
                end                       no_of_months
            from
                ar_invoice_lines a,
                pay_reason       b,
                lookups          l
            where
                    invoice_id = p_invoice_id
                and l.lookup_name = 'INVOICE_LINE_TYPE'
                and invoice_line_type in ( 'ACTIVE_ADJUSTMENT', 'ADJUSTMENT' )
                and a.invoice_line_type = l.lookup_code
                and a.rate_code = to_char(b.reason_code)
                and a.status <> 'VOID'
        ) loop
            l_record.description := x.description;
            l_record.quantity := x.quantity;
            l_record.unit_rate_cost := x.unit_rate_cost;
            l_record.total_line_amount := x.total_line_amount;
            l_record.no_of_months := x.no_of_months;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_adj_invdetail;

    function get_claim_invdetail (
        p_invoice_id in number
    ) return invoice_tbl
        pipelined
        deterministic
    is
        l_record invoice_rec;
    begin
        for x in (
            select
                b.reason_name,
                a.description,
                a.quantity,
                a.unit_rate_cost,
                nvl(a.total_line_amount, 0) total_line_amount
            from
                ar_invoice_lines a,
                pay_reason       b,
                ar_invoice       c
            where
                    a.invoice_id = p_invoice_id
                and a.status <> 'VOID'
                and a.invoice_id = c.invoice_id
                and c.invoice_reason = 'CLAIM'
                and a.rate_code = to_char(b.reason_code)
        ) loop
            l_record.description := x.description;
            l_record.quantity := x.quantity;
            l_record.unit_rate_cost := x.unit_rate_cost;
            l_record.total_line_amount := x.total_line_amount;
            l_record.reason_name := x.reason_name;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_claim_invdetail;

    function get_payment_received (
        p_invoice_id in number
    ) return payreceived_tbl
        pipelined
        deterministic
    is
        l_record paymentreceived_rec;
    begin
        for x in (
            select
                ep.check_date,
                ep.check_number,
                ep.check_amount,
                pc_lookups.get_reason_name(ep.reason_code) reason_name,
                nvl(ep.plan_type, a.account_type)          plan_type,
                ep.note
            from
                employer_payments ep,
                account           a
            where
                    invoice_id = p_invoice_id
                and ep.entrp_id = a.entrp_id
            union
            select
                check_date,
                check_number,
                check_amount,
                pc_lookups.get_fee_reason(reason_code) reason_name,
                plan_type,
                note
            from
                employer_deposits
            where
                invoice_id = p_invoice_id
        ) loop
            l_record.check_date := x.check_date;
            l_record.check_number := x.check_number;
            l_record.check_amount := x.check_amount;
            l_record.reason_name := x.reason_name;
            l_record.plan_type := x.plan_type;
            l_record.note := x.note;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_payment_received;

    function get_invoice_info (
        p_invoice_num    in number,
        p_status_code    in varchar2,
        p_division_code  in varchar2,
        p_invoice_reason in varchar2,
        p_acc_num        in varchar2,
        p_from_date      in varchar2,
        p_to_date        in varchar2,
        p_flag           in varchar2,
        p_start_row      in number,
        p_end_row        in number,
        p_sort_column    in varchar2,
        p_sort_order     in varchar2
    ) return ar_invoice_t
        pipelined
        deterministic
    is

        l_record_t       ar_invoice_row_t;
        v_order          varchar2(1000);
        v_sql_1          varchar2(4000);
        v_sql_2          varchar2(4000);
        v_sql            varchar2(4000);
        v_status_code    varchar2(4000);
        v_order_clause_1 varchar2(4000);
        v_division_code  varchar2(250) := p_division_code;
        v_order_clause   varchar2(250);
        v_order_clause_2 varchar2(250);
        v_sql_cur        l_cursor;
        v_from_date      date;
        v_to_date        date;
        v_sort_column    varchar2(250);
        v_sort_order     varchar2(10);
    begin
        if is_date(p_from_date, 'DD-MON-YYYY') = 'Y' then
            v_from_date := to_date ( p_from_date, 'DD/MM/YYYY' );
        else
            v_from_date := null;
        end if;

        if
            v_from_date is not null
            and is_date(p_to_date, 'DD-MON-YYYY') = 'Y'
        then
            v_to_date := to_date ( p_to_date, 'DD/MM/YYYY' );
        else
            v_to_date := null;
            v_from_date := null;
        end if;

        if nvl(p_division_code, '*') in ( '*', 'ALL_DIVISION', 'NO_DIVISION' ) then
            v_division_code := '*';
        end if;

        if nvl(p_sort_column, '*') in ( 'INVOICE_ID', 'INVOICE_REASON', 'INVOICE_DATE', 'INVOICE_DUE_DATE', 'INVOICE_AMOUNT',
                                        'REFUND_AMOUNT', 'PAID_AMOUNT' ) then
            v_sort_column := p_sort_column;
        end if;

        if p_flag = '1' then
            v_order_clause_1 := ' ORDER BY INVOICE_ID';
        elsif p_flag = '2' then
            v_order_clause_1 := ' ORDER BY INVOICE_NUMBER';
        elsif p_flag in ( '3', '4' ) then
            if
                nvl(
                    rtrim(ltrim(p_sort_order)),
                    '*'
                ) in ( 'ASC', 'DESC' )
                and nvl(v_sort_column, '*') <> '*'
            then
                v_sort_order := p_sort_order;
                v_order := ' order by '
                           || v_sort_column
                           || ' '
                           || v_sort_order;
            else
                v_sort_order := 'DESC';
                v_sort_column := 'INVOICE_DUE_DATE';
                v_order := ' order by '
                           || v_sort_column
                           || ' '
                           || v_sort_order;
            end if;
        end if;

        if p_flag in ( '1', '2' ) then
            v_sql_1 := 'SELECT  E.INVOICE_NUMBER
                       ,to_char(E.INVOICE_DATE,''dd-mon-yyyy'')
                       ,to_char(E.INVOICE_DUE_DATE,''dd-mon-yyyy'')
                       ,CASE WHEN INVOICE_AMOUNT = NVL(REFUND_AMOUNT,0) THEN ''REFUNDED'' ELSE E.STATUS_CODE END STATUS_CODE
                       ,E.STATUS
                       ,to_char(E.INVOICE_POSTED_DATE,''dd-mon-yyyy'')
                       ,E.INVOICE_ID
                       ,E.ENTRP_ID
                       ,E.ACC_ID
                       ,E.ACC_NUM
                       ,E.INVOICE_TERM
                       ,to_char(E.START_DATE,''dd-mon-yyyy'')
                       ,to_char(E.END_DATE,''dd-mon-yyyy'')
                       ,E.COVERAGE_PERIOD
                       ,E.COMMENTS
                       ,E.AUTO_PAY
                       ,E.BILLING_NAME
                       ,E.BILLING_ADDRESS
                       ,E.BILLING_CITY
                       ,E.BILLING_ZIP
                       ,E.BILLING_STATE
                       ,E.BILLING_ATTN
                       ,E.PAYMENT_METHOD
                       ,E.INVOICE_STATUS
                       ,E.INVOICE_REASON
                       ,E.DIVISION_CODE
                       ,E.REFUND_AMOUNT
                       ,E.INVOICE_AMOUNT
                       ,E.PENDING_AMOUNT
                       ,E.PAID_AMOUNT
                       ,E.VOID_AMOUNT
                       ,E.ENTITY_ID
                       ,E.ENTITY_TYPE
                       ,E.PLAN_TYPE
                       ,Null    DIVISION_NAME
					   ,ROWNUM
               FROM AR_INVOICE_V e
              WHERE e.acc_num = '''
                       || p_acc_num
                       || '''
--				AND ('''
                       || p_status_code
                       || ''' = ''ALL_STATUS'' AND e.STATUS_CODE IN (''PROCESSED'',''POSTED'',''PARTIALLY_POSTED'',''IN_PROCESS'')
--				           OR e.STATUS_CODE = '''
                       || p_status_code
                       || ''' )
                AND ( ('''
                       || p_status_code
                       || ''' = ''ALL_STATUS'' AND e.STATUS_CODE IN (''PROCESSED'',''POSTED'',''PARTIALLY_POSTED'',''IN_PROCESS''))
                           OR ( '''
                       || p_status_code
                       || ''' = ''REFUNDED'' AND E.INVOICE_AMOUNT = E.REFUND_AMOUNT AND E.INVOICE_AMOUNT >0)
				           OR ( e.STATUS_CODE = '''
                       || p_status_code
                       || ''' AND NVL(REFUND_AMOUNT,0) <> E.INVOICE_AMOUNT) )
			    AND e.INVOICE_REASON = '''
                       || p_invoice_reason
                       || '''
                AND e.Invoice_ID   = NVL('''
                       || p_invoice_num
                       || ''',e.Invoice_ID)
                AND pc_invoice.get_charged_to(e.invoice_id) = ''EMPLOYER''   -- Added by Jaggi for 11484
                AND NVL(e.DIVISION_CODE,''*'')   = Decode('''
                       || v_division_code
                       || ''',''*'',NVL(e.DIVISION_CODE,''*''),'''
                       || v_division_code
                       || ''')
				AND Trunc(e.INVOICE_DATE) >= NVL('''
                       || trunc(v_from_date)
                       || ''',Trunc(e.INVOICE_DATE)) AND Trunc(e.INVOICE_DATE) <= NVL('''
                       || trunc(v_to_date)
                       || ''',Trunc(e.INVOICE_DATE))';
											  --- Ticket#5494 RPRABU 27/06/2019 Trunc

            pc_log.log_error('PC_INVOICE.GET_INVOICE_INFO 333 :', 'v_sql_1' || v_sql_1);
            v_status_code := 'AND e.STATUS_CODE NOT IN (''VOID'',''DRAFT'')';
        elsif p_flag in ( '3', '4' ) then
            v_sql_2 := 'SELECT outer.*
            FROM (SELECT ROWNUM rn, inner.*
                 FROM (SELECT CASE WHEN INVOICE_AMOUNT = NVL(REFUND_AMOUNT,0) THEN ''REFUNDED'' ELSE E.STATUS_CODE END STATUS_CODE,
                        e.PENDING_AMOUNT,e.COMMENTS, e.INVOICE_NUMBER, to_char(e.INVOICE_DATE,''dd-mon-yyyy''), to_char(e.INVOICE_DUE_DATE,''dd-mon-yyyy''),
				       (e.INVOICE_AMOUNT - NVL(e.VOID_AMOUNT,0)) INVOICE_AMOUNT  ,E.REFUND_AMOUNT,E.PAID_AMOUNT,e.COVERAGE_PERIOD,
					   e.STATUS,to_char(e.INVOICE_POSTED_DATE,''dd-mon-yyyy''),e.INVOICE_ID,e.INVOICE_REASON,e.DIVISION_CODE,
					   e.PAYMENT_METHOD, PC_EMPLOYER_DIVISIONS.GET_DIVISION_NAME(DIVISION_CODE,ENTRP_ID) DIVISION_NAME
					   FROM  AR_INVOICE_V e
			   WHERE e.ACC_NUM = '''
                       || p_acc_num
                       || '''
                 AND e.Invoice_ID   = NVL('''
                       || p_invoice_num
                       || ''',e.Invoice_ID)
                 AND pc_invoice.get_charged_to(e.invoice_id) = ''EMPLOYER''   -- Added by Jaggi for 11484
                 AND NVL(e.DIVISION_CODE,''*'')   = Decode('''
                       || v_division_code
                       || ''',''*'',NVL(e.DIVISION_CODE,''*''),'''
                       || v_division_code
                       || ''')
                 AND e.INVOICE_REASON = '''
                       || p_invoice_reason
                       || '''
--				 AND  ('''
                       || p_status_code
                       || ''' = ''ALL_STATUS'' AND e.status_code IN (''PROCESSED'',''POSTED'',''PARTIALLY_POSTED'',''IN_PROCESS'')
--				 OR   e.status_code = '''
                       || p_status_code
                       || ''')
                 AND ( ('''
                       || p_status_code
                       || ''' = ''ALL_STATUS'' AND e.STATUS_CODE IN (''PROCESSED'',''POSTED'',''PARTIALLY_POSTED'',''IN_PROCESS''))
                     OR ( '''
                       || p_status_code
                       || ''' = ''REFUNDED'' AND E.INVOICE_AMOUNT = E.REFUND_AMOUNT AND E.INVOICE_AMOUNT >0)
				      OR ( e.STATUS_CODE = '''
                       || p_status_code
                       || ''' AND NVL(REFUND_AMOUNT,0) <> E.INVOICE_AMOUNT) )
				 AND Trunc(e.INVOICE_DATE) >= NVL('''
                       || trunc(v_from_date)
                       || ''',Trunc(e.INVOICE_DATE)) AND Trunc(e.INVOICE_DATE) <= NVL('''
                       || trunc(v_to_date)
                       || ''',Trunc(e.INVOICE_DATE))
                  '
                       || v_order
                       || ' ) inner) outer
                WHERE outer.rn >= '''
                       || p_start_row
                       || ''' AND outer.rn <= '''
                       || p_end_row
                       || '''';
                    --- Ticket#5494 RPRABU 27/06/2019 Trunc

            pc_log.log_error('PC_INVOICE.GET_INVOICE_INFO 444 :', 'v_sql_2' || v_sql_2);
        end if;

        if p_flag = '1' then
            v_sql := v_sql_1
                     || v_status_code
                     || v_order_clause_1;
        elsif p_flag = '2' then
            v_sql := v_sql_1 || v_order_clause_1;
        elsif p_flag in ( '3', '4' ) then
            v_sql := v_sql_2;
        end if;

        if p_flag in ( '1', '2' ) then
            open v_sql_cur for v_sql;

            loop
                fetch v_sql_cur into
                    l_record_t.invoice_number,
                    l_record_t.invoice_date,
                    l_record_t.invoice_due_date,
                    l_record_t.status_code,
                    l_record_t.status,
                    l_record_t.invoice_posted_date,
                    l_record_t.invoice_id,
                    l_record_t.entrp_id,
                    l_record_t.acc_id,
                    l_record_t.acc_num,
                    l_record_t.invoice_term,
                    l_record_t.start_date,
                    l_record_t.end_date,
                    l_record_t.coverage_period,
                    l_record_t.comments,
                    l_record_t.auto_pay,
                    l_record_t.billing_name,
                    l_record_t.billing_address,
                    l_record_t.billing_city,
                    l_record_t.billing_zip,
                    l_record_t.billing_state,
                    l_record_t.billing_attn,
                    l_record_t.payment_method,
                    l_record_t.invoice_status,
                    l_record_t.invoice_reason,
                    l_record_t.division_code,
                    l_record_t.refund_amount        -- Added by Jaggi ##9980
                    ,
                    l_record_t.invoice_amount,
                    l_record_t.pending_amount,
                    l_record_t.paid_amount,
                    l_record_t.void_amount,
                    l_record_t.entity_id,
                    l_record_t.entity_type,
                    l_record_t.plan_type,
                    l_record_t.division_name,
                    l_record_t.rownum_1;

                exit when v_sql_cur%notfound;
                pipe row ( l_record_t );
            end loop;

            close v_sql_cur;
        elsif p_flag in ( '3', '4' ) then
            open v_sql_cur for v_sql;

            loop
                fetch v_sql_cur into
                    l_record_t.rownum_1,
                    l_record_t.status_code,
                    l_record_t.pending_amount,
                    l_record_t.comments,
                    l_record_t.invoice_number,
                    l_record_t.invoice_date,
                    l_record_t.invoice_due_date,
                    l_record_t.invoice_amount,
                    l_record_t.refund_amount        -- Added by Jaggi ##9980
                    ,
                    l_record_t.paid_amount,
                    l_record_t.coverage_period,
                    l_record_t.status,
                    l_record_t.invoice_posted_date,
                    l_record_t.invoice_id,
                    l_record_t.invoice_reason,
                    l_record_t.division_code,
                    l_record_t.payment_method,
                    l_record_t.division_name;

                exit when v_sql_cur%notfound;
                pipe row ( l_record_t );
            end loop;

            close v_sql_cur;
        end if;

    exception
        when others then
            null;
    end get_invoice_info;

-- This Function is a copy of from PC_INVOICE_REPORTS.GET_TAX
-- PC_INVOICE_REPORTS is not used in production, hence used copy of it in this package
    function get_invoice_tax (
        p_invoice_id in number
    ) return invoice_line_tbl
        pipelined
        deterministic
    is
        l_record invoice_line_rec;
    begin
        for x in (
            select
                a.description,
                quantity,
                unit_rate_cost,
                nvl(total_line_amount, 0) total_line_amount,
                1
            from
                ar_invoice_lines a,
                pay_reason       b
            where
                    invoice_id = p_invoice_id
                and nvl(invoice_line_type, '-1') = 'TAX'
                and a.status <> 'VOID'
                and a.rate_code = to_char(b.reason_code)
        ) loop
            l_record.description := x.description;
            l_record.unit_rate_cost := x.unit_rate_cost;
            l_record.total_line_amount := x.total_line_amount;
            l_record.no_of_months := 1;
            l_record.quantity := x.quantity;
            pipe row ( l_record );
        end loop;
    exception
        when others then
            null;
    end get_invoice_tax;
-- End of Addition by swamy for sql injection
  -- Vantha : Service charge changes

    procedure insert_rate_plan_detail (
        p_rate_plan_id       in number,
        p_calculation_type   in varchar2,
        p_minimum_range      in number,
        p_maximum_range      in number,
        p_description        in varchar2,
        p_rate_code          in varchar2,
        p_rate_plan_cost     in number,
        p_rate_basis         in varchar2,
        p_effective_date     in date,
        p_effective_end_date in date,
        p_one_time_flag      in varchar2,
        p_invoice_param_id   in number,
        p_user_id            in number,
        p_charged_to         in varchar2   -- added by swamy for ticket#11119
    ) is
    begin
        pc_log.log_error('INSERT_RATE_PLAN_DETAIL', 'P_RATE_CODE: '
                                                    || p_rate_code
                                                    || 'P_ONE_TIME_FLAG: '
                                                    || p_one_time_flag
                                                    || ' P_INVOICE_PARAM_ID :='
                                                    || p_invoice_param_id);

        insert into rate_plan_detail (
            rate_plan_detail_id,
            rate_plan_id,
            calculation_type,
            minimum_range,
            maximum_range,
            description,
            rate_code,
            rate_plan_cost,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            rate_basis,
            effective_date,
            effective_end_date,
            one_time_flag,
            invoice_param_id,
            charged_to      -- added by swamy for ticket#11119
        ) values ( rate_plan_detail_seq.nextval,
                   p_rate_plan_id,
                   p_calculation_type,
                   p_minimum_range,
                   p_maximum_range,
                   p_description,
                   p_rate_code,
                   p_rate_plan_cost,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   p_rate_basis,
                   p_effective_date,
                   p_effective_end_date,
                   p_one_time_flag,
                   p_invoice_param_id,
                   nvl(p_charged_to, 'EMPLOYER')  -- added by swamy for ticket#11119
                    );

    end insert_rate_plan_detail;

    procedure apply_service_charge (
        p_batch_number in number
    ) is

        l_invoice_line_id  number;
        l_inv_line_count   number := 0;
        l_service_charge   number := 0;
        l_calculation_type varchar2(30);
        l_renewal_count    number := 0;
        l_void_count       number := 0;
    begin
        pc_log.log_error('PC_INVOICE.Apply service charge entered procedure', 'procedure');

                 -- Applying Tax
        for x in (
            select
                a.invoice_id,
                a.rate_plan_id,
                p.reason_mapping,
                a.billing_date,
                arl.rate_code,
                nvl(p.product_type, acc.account_type) product_type,
                acc.entrp_id,
                sum(arl.total_line_amount)            invoice_amount,
                a.status
            from
                ar_invoice       a,
                ar_invoice_lines arl,
                pay_reason       p,
                account          acc
            where
                    a.batch_number = p_batch_number
                and arl.invoice_line_type = 'FLAT_FEE'
                and a.status in ( 'DRAFT', 'GENERATED' )
                and a.entity_id = acc.entrp_id
                and a.invoice_id = arl.invoice_id
                and to_char(p.reason_code) = arl.rate_code
                and ( ( p.reason_mapping = '1'
                        and acc.enrollment_source in ( 'PAPER', 'INTERNAL' ) )
                      or p.reason_mapping = '30' )
                and p.reason_mapping in ( '1', '30' )
                and arl.status <> 'VOID'
                and acc.account_type <> 'ACA'
            group by
                a.invoice_id,
                a.rate_plan_id,
                p.reason_mapping,
                a.billing_date,
                arl.rate_code,
                p.product_type,
                acc.account_type,
                acc.entrp_id,
                a.status
            having
                sum(arl.total_line_amount) > 0
        ) loop
            pc_log.log_error('PC_INVOICE.Apply service charge entered loop', 'llop');
            l_inv_line_count := 0;
            select
                count(*)
            into l_inv_line_count
            from
                ar_invoice       a,
                ar_invoice_lines arl
            where
                    a.invoice_id = x.invoice_id
                and arl.invoice_line_type = case
                    when x.reason_mapping = '1'  then
                        'SETUP_SERVICE_CHARGE'
                    when x.reason_mapping = '30' then
                        'RENEWAL_SERVICE_CHARGE'
                                            end
                and a.invoice_id = arl.invoice_id
                and arl.status <> 'VOID'
                and ( arl.product_type is null
                      or arl.product_type = nvl(x.product_type, product_type) );

            l_void_count := 0;
            select
                count(*)
            into l_void_count
            from
                ar_invoice       a,
                ar_invoice_lines arl
            where
                    a.invoice_id = x.invoice_id
                and arl.rate_code = '88'
                and a.invoice_id = arl.invoice_id
                and arl.status = 'VOID'
                and ( arl.product_type is null
                      or arl.product_type = nvl(x.product_type, product_type) );

            pc_log.log_error('PC_INVOICE.Apply service charge X.RATE_PLAN_ID: ', x.rate_plan_id);
            pc_log.log_error('PC_INVOICE.Apply service charge  x.billing_date: ', x.billing_date);
            for xx in (
                select
                    rate_plan_cost,
                    calculation_type,
                    effective_date,
                    rate_basis
                from
                    rate_plan_detail
                where
                        rate_plan_id = x.rate_plan_id
                    and rate_basis = case
                        when x.reason_mapping = '1'  then
                            'SETUP_SERVICE_CHARGE'
                        when x.reason_mapping = '30' then
                            'RENEWAL_SERVICE_CHARGE'
                                     end
                    and nvl(effective_end_date, sysdate) >= x.billing_date
            ) loop
                pc_log.log_error('PC_INVOICE.Apply service charge into renewal count loop: ', 'loop');
                pc_log.log_error('PC_INVOICE.Apply service charge into renewal RATE_PLAN_COST: ', xx.rate_plan_cost);
                pc_log.log_error('PC_INVOICE.Apply service charge into renewal CALCULATION_TYPE: ', xx.calculation_type);
                pc_log.log_error('PC_INVOICE.Apply service charge into renewal effective_date: ', xx.effective_date);
                pc_log.log_error('PC_INVOICE.Apply service charge into renewal RATE_BASIS: ', xx.rate_basis);
                select
                    count(*)
                into l_renewal_count
                from
                    ben_plan_enrollment_setup bp
                where
                        entrp_id = x.entrp_id
                    and ben_plan_id_main is null
                    and not exists (
                        select
                            *
                        from
                            ben_plan_renewals br
                        where
                            br.renewed_plan_id = bp.ben_plan_id
                    )
                    and exists (
                        select
                            *
                        from
                            ben_plan_enrollment_setup bp1
                        where
                                bp1.entrp_id = bp.entrp_id
                            and bp.plan_start_date > bp1.plan_start_date
                    )
                    and xx.effective_date between bp.plan_start_date and bp.plan_end_date;

                pc_log.log_error('PC_INVOICE.Apply service charge l_renewal_count: ', l_renewal_count);
                if l_renewal_count > 0 then
                    l_calculation_type := xx.calculation_type;
                    l_service_charge := xx.rate_plan_cost;
                end if;

            end loop;

            if
                l_service_charge is not null
                and l_void_count = 0
            then
                if l_inv_line_count > 0 then
                    update ar_invoice_lines
                    set
                        unit_rate_cost = round(l_service_charge / 100, 2),
                        total_line_amount = round(x.invoice_amount * l_service_charge / 100, 2),
                        product_type = x.product_type,
                        calculation_type = l_calculation_type
                    where
                            invoice_id = x.invoice_id
                        and invoice_line_type = case
                            when x.reason_mapping = '1'  then
                                'SETUP_SERVICE_CHARGE'
                            when x.reason_mapping = '30' then
                                'RENEWAL_SERVICE_CHARGE'
                                                end;

                else
                    pc_log.log_error('PC_INVOICE.Apply service charge. l_service_charge : ', l_service_charge);
                    if nvl(l_service_charge, 0) > 0 then
                        pc_invoice.insert_invoice_line(
                            p_invoice_id        => x.invoice_id,
                            p_invoice_line_type =>
                                                 case
                                                     when x.reason_mapping = '1'  then
                                                         'SETUP_SERVICE_CHARGE'
                                                     when x.reason_mapping = '30' then
                                                         'RENEWAL_SERVICE_CHARGE'
                                                 end,
                            p_rate_code         => '88',
                            p_description       => 'Service charge for Manual Enrollment/Renewal',
                            p_quantity          => 1,
                            p_no_of_months      => 1,
                            p_rate_cost         => round(l_service_charge / 100, 2),
                            p_total_cost        => round(x.invoice_amount * l_service_charge / 100, 2),
                            p_batch_number      => p_batch_number,
                            x_invoice_line_id   => l_invoice_line_id
                        );

                        pc_log.log_error('PC_INVOICE.Apply service charge. l_invoice_line_id : ', l_invoice_line_id);
                        update ar_invoice_lines
                        set
                            product_type = x.product_type,
                            calculation_type = l_calculation_type,
                            status = x.status -- 'GENERATED' added by Joshi for invoice amount mismatch prod issue 9605
                        where
                            invoice_line_id = l_invoice_line_id;

                        update rate_plan_detail
                        set
                            effective_end_date = sysdate
                        where
                                rate_plan_id = x.rate_plan_id
                            and rate_basis = case
                                when x.reason_mapping = '1'  then
                                    'SETUP_SERVICE_CHARGE'
                                when x.reason_mapping = '30' then
                                    'RENEWAL_SERVICE_CHARGE'
                                             end
                            and effective_end_date is null;

                    end if;

                end if;
            end if;

        end loop;

    end apply_service_charge;

-- Added by Swamy for Ticket#8037
    procedure hsa_auto_invoice_approval is
    begin
        for i in (
            select
                a.invoice_id
            from
                ar_invoice a,
                account    b
            where
                    a.status = 'GENERATED'
                and a.acc_num = b.acc_num
                and b.account_type in ( 'HSA', 'LSA' )   -- LSA Added by Swamy for Ticket#11261, LSA should be auto approved on 28th of every month
                and a.invoice_id is not null
                 --AND Invoice_Id in ('164841','164904','164905')
            order by
                a.invoice_id
        ) loop
            pc_log.log_error('SAM:approve_invoice', 'P_INVOICE_ID' || i.invoice_id);
            pc_invoice.approve_invoice(i.invoice_id, '0');
        end loop;
    exception
        when others then
            null;
    end hsa_auto_invoice_approval;

    procedure generate_monthly_fee_comp (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_entrp_id      in number,
        p_account_type  in varchar2 default null,
        x_error_status  out varchar2,
        x_error_message out varchar2,
        p_invoice_type  in varchar2 default null,
        p_division_code in varchar2 default null,
        x_batch_number  out number
    ) is
        l_batch_number number;
    begin
        select
            invoice_batch_seq.nextval
        into l_batch_number
        from
            dual;

 -- Monthly  time invoice
        insert into ar_invoice (
            invoice_id,
            invoice_number,
            invoice_date,
            billing_date,
            invoice_due_date,
            invoice_type,
            invoice_amount,
            pending_amount,
            acc_id,
            acc_num,
            entity_id,
            entity_type,
            invoice_term,
            auto_pay,
            rate_plan_id,
            payment_method,
            batch_number,
            status,
            last_invoiced_date,
            start_date,
            end_date,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            bank_acct_id,
            billing_name,
            billing_attn,
            billing_address,
            billing_city,
            billing_zip,
            billing_state
        )
            select
                ar_invoice_seq.nextval,
                invoice_number_seq.nextval,
                nvl(p_billing_date,
                    to_date('10-'
                            || to_char(sysdate, 'MON-YYYY'),
                    'DD-MON-YYYY'))                        invoice_date,
                nvl(p_billing_date,
                    to_date('10-'
                            || to_char(sysdate, 'MON-YYYY'),
                    'DD-MON-YYYY'))                        billing_date,
                decode(p_billing_date,
                       null,
                       to_date('10-'
                               || to_char(sysdate, 'MON-YYYY'),
                       'DD-MON-YYYY'),
                       sysdate) + decode(a.payment_term,
                                         'NET7',
                                         7,
                                         'NET60',
                                         60,
                                         'NET30',
                                         30,
                                         'NET15',
                                         15,
                                         'NET90',
                                         90,
                                         'PIA',
                                         1,
                                         'IMMEDIATE',
                                         5,
                                         round(add_bus_days(sysdate, 4) - sysdate)) invoice_due_date,
                'AUTO',
                0,
                0,
                b.acc_id,
                b.acc_num,
                b.entrp_id,
                'EMPLOYER',
                a.payment_term,
                a.autopay,
                c.rate_plan_id,
                a.payment_method,
                l_batch_number,
                'DRAFT',
                a.last_invoiced_date,
                p_start_date,
                p_end_date,
                0,
                sysdate,
                0,
                sysdate,
                a.bank_acct_id,
                billing_name,
                billing_attn,
                billing_address,
                billing_city,
                billing_zip,
                billing_state
            from
                invoice_parameters a,
                account            b,
                rate_plans         c
            where
                    b.entrp_id = nvl(p_entrp_id, b.entrp_id)
                and a.entity_id = b.entrp_id
                and a.entity_type = 'EMPLOYER'
                and c.entity_id = a.entity_id
                and a.rate_plan_id = c.rate_plan_id
                and c.entity_type = a.entity_type
                and c.status = 'A'
                and a.status = 'A'
                and a.invoice_type = 'FEE'
                and c.division_code is null
                and a.division_code is null
                and b.account_type = p_account_type
                and c.rate_plan_type = 'INVOICE'
                and trunc(c.effective_date) <= p_end_date
                and ( c.effective_end_date is null
                      or c.effective_end_date >= p_end_date
                      or c.effective_end_date between p_start_date and p_end_date )
                and a.invoice_frequency <> 'QUARTERLY'
                and nvl(c.division_invoicing, 'N') = 'N'
--    AND A.PAYMENT_METHOD = 'DIRECT_DEPOSIT' -- commented by Joshi for 11061
                and a.invoice_frequency = 'MONTHLY';

        process_pop_erisa_5500_inv(
            p_start_date        => p_start_date,
            p_end_date          => p_end_date,
            p_billing_date      => p_billing_date,
            p_entrp_id          => p_entrp_id,
            p_batch_number      => l_batch_number,
            p_invoice_frequency => 'MONTHLY',
            x_error_status      => x_error_status,
            x_error_message     => x_error_message
        );

        delete from ar_invoice
        where
            not exists (
                select
                    *
                from
                    ar_invoice_lines
                where
                    invoice_id = ar_invoice.invoice_id
            )
                and status = 'DRAFT'
                and trunc(creation_date) = trunc(sysdate)
                and batch_number = l_batch_number;

        if sql%rowcount > 0 then
            x_batch_number := null;
        else
            x_batch_number := l_batch_number;
        end if;

    exception
    --  WHEN INVOICE_EXCEPTION THEN
    --    RAISE_APPLICATION_ERROR('-20001',l_error_message);
    --    rollback;
        when others then
            x_error_status := 'E';
        --x_error_message := nvl(l_error_message,substr(sqlerrm,1,200));
            pc_log.log_error('PC_INVOICE.generate_invoice',
                             'Error message '
                             || nvl(x_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end generate_monthly_fee_comp;

-- Added by Jaggi for 9142
    function get_inv_info_for_broker (
        p_entity_id    in number,
        p_entity_type  in varchar2,
        p_status_code  in varchar2,
        p_acc_num      in varchar2,
        p_product_type in varchar2,
        p_from_date    in varchar2,
        p_to_date      in varchar2,
        p_flag         in varchar2,
        p_start_row    in number,
        p_end_row      in number,
        p_sort_column  in varchar2,
        p_sort_order   in varchar2
    ) return ar_invoice_t
        pipelined
        deterministic
    is

        l_record_t       ar_invoice_row_t;
        v_order          varchar2(1000);
        v_sql_1          varchar2(4000);
        v_sql_2          varchar2(4000);
        v_sql            varchar2(4000);
        v_status_code    varchar2(4000);
        v_product_type   varchar2(4000);
        l_status_code    varchar2(4000);
        v_order_clause_1 varchar2(4000);
        v_order_clause   varchar2(250);
        v_order_clause_2 varchar2(250);
        v_sql_cur        l_cursor;
        v_from_date      date;
        v_to_date        date;
        v_sort_column    varchar2(250);
        v_sort_order     varchar2(10);
        v_acc_id         number;
        v_entity_id      varchar2(10);
    begin
        v_acc_id := null;
        begin
            if p_acc_num is not null then
                select
                    acc_id
                into v_acc_id
                from
                    account
                where
                    acc_num = p_acc_num;

            end if;

        exception
            when no_data_found then
                v_acc_id := null;
        end;

        if p_entity_type = 'GA' then
            v_entity_id := 'GA_ID';
        elsif p_entity_type = 'BROKER' then
            v_entity_id := 'BROKER_ID';
        end if;

        if is_date(p_from_date, 'DD-MON-YYYY') = 'Y' then
            v_from_date := to_date ( p_from_date, 'DD/MM/YYYY' );
        else
            v_from_date := null;
        end if;

        if
            v_from_date is not null
            and is_date(p_to_date, 'DD-MON-YYYY') = 'Y'
        then
            v_to_date := to_date ( p_to_date, 'DD/MM/YYYY' );
        else
            v_to_date := null;
            v_from_date := null;
        end if;

        if nvl(p_status_code, '*') in ( '*', 'ALL_STATUS' ) then
     -- L_status_code :=  'PROCESSED'''||','||'''POSTED'''||','||'''PARTIALLY_POSTED';
            l_status_code := 'PROCESSED'''
                             || ','
                             || '''POSTED'''
                             || ','
                             || '''PARTIALLY_POSTED'
                             || ','
                             || '''IN_PROCESS';
        else
            l_status_code := p_status_code;
        end if;

        if nvl(p_product_type, '*') in ( '*', 'ALL_PRODUCT' ) then
            v_product_type := 'ERISA_WRAP'''
                              || ','
                              || '''FORM_5500'''
                              || ','
                              || '''RB'''
                              || ','
                              || '''POP'''
                              || ','
                              || '''ACA'''
                              || ','
                              || '''FSA'''
                              || ','
                              || '''HRA'''
                              || ','
                              || '''HSA'''
                              || ','
                              || '''COBRA'''
                              || ','
                              || '''CMP'''
                              || ','
                              || '''FMLA'''
                              || ','
                              || '''LSA';
        else
            v_product_type := p_product_type;
        end if;

        if nvl(p_sort_column, '*') in ( 'INVOICE_ID', 'INVOICE_REASON', 'INVOICE_NUMBER', 'INVOICE_DATE', 'EMPLOYER_NAME',
                                        'ACC_NUM', 'INVOICE_AMOUNT', 'REFUND_AMOUNT', 'PAID_AMOUNT' ) then
            v_sort_column := p_sort_column;
        end if;

        if p_flag = '1' then
            v_order_clause_1 := ' ORDER BY INVOICE_ID';
        elsif p_flag = '2' then
            v_order_clause_1 := ' ORDER BY INVOICE_NUMBER';
        elsif p_flag in ( '3', '4' ) then
            if
                nvl(
                    rtrim(ltrim(p_sort_order)),
                    '*'
                ) in ( 'ASC', 'DESC' )
                and nvl(v_sort_column, '*') <> '*'
            then
                v_sort_order := p_sort_order;
                v_order := ' order by E.'
                           || v_sort_column
                           || ' '
                           || v_sort_order;
            else
                v_sort_order := 'DESC';
                v_sort_column := 'INVOICE_DUE_DATE';
                v_order := ' order by '
                           || v_sort_column
                           || ' '
                           || v_sort_order;
            end if;
        end if;

    -- Added the status "IN_PROCESS" for 12557 by Joshi.
        if p_flag in ( '1', '2' ) then
            v_sql_1 := 'SELECT  E.INVOICE_NUMBER
                           ,to_char(E.INVOICE_DATE,''dd-mon-yyyy'') INVOICE_DATE 
                           ,E.INVOICE_DUE_DATE
                           ,E.STATUS_CODE
                           ,E.STATUS
                           ,E.INVOICE_POSTED_DATE
                           ,E.INVOICE_ID
                           ,E.ENTRP_ID
                           ,E.EMPLOYER_NAME
                           ,E.ACC_ID
                           ,E.ACC_NUM
                           ,E.ACCOUNT_TYPE
                           ,E.INVOICE_TERM
                           ,E.START_DATE
                           ,E.END_DATE
                           ,E.COVERAGE_PERIOD
                           ,E.COMMENTS
                           ,E.AUTO_PAY
                           ,E.BILLING_NAME
                           ,E.BILLING_ADDRESS
                           ,E.BILLING_CITY
                           ,E.BILLING_ZIP
                           ,E.BILLING_STATE
                           ,E.BILLING_ATTN
                           ,E.PAYMENT_METHOD
                           ,E.INVOICE_STATUS
                           ,E.INVOICE_REASON
                           ,E.DIVISION_CODE
                           ,E.REFUND_AMOUNT
                           ,E.INVOICE_AMOUNT
                           ,E.PENDING_AMOUNT
                           ,E.PAID_AMOUNT
                           ,E.VOID_AMOUNT
                           ,E.ENTITY_ID
                           ,E.ENTITY_TYPE
                           ,E.PLAN_TYPE
                           ,E.CREATED_BY
                           ,E.ENROLLE_TYPE
                           ,ROWNUM ROW_NUM
                       FROM UI_INVOICE_QUERY_V E
                      WHERE e.acc_id = NVL('''
                       || v_acc_id
                       || ''',E.ACC_ID)
                        AND E.'
                       || v_entity_id
                       || ' = '
                       || p_entity_id
                       || '
                        AND exists ( SELECT  a.*
                                         FROM AR_INVOICE A, ar_invoice_lines ARL, RATE_PLAN_DETAIL R
                                         WHERE A.INVOICE_ID = e.invoice_id
                                           AND A.INVOICE_ID = ARL.INVOICE_ID
                                           AND A.RATE_PLAN_ID = R.RATE_PLAN_ID
                                           AND R.RATE_CODE = ARL.RATE_CODE
                                           AND TRUNC(R.EFFECTIVE_DATE) <= A.END_DATE
                                         --  AND  ( R.EFFECTIVE_END_DATE IS NULL  OR R.EFFECTIVE_END_DATE  >= A.END_DATE)
                                           AND ( (R.EFFECTIVE_END_DATE IS NULL OR R.EFFECTIVE_END_DATE >= e.END_DATE)
                                             OR ( R.EFFECTIVE_END_DATE IS NOT NULL AND E.END_DATE >=R.EFFECTIVE_END_DATE ))
                                        AND  NVL(a.charged_to,r.charged_to) = '''
                       || p_entity_type
                       || ''' )                  
                          AND ( ('''
                       || p_status_code
                       || ''' = ''ALL_STATUS'' AND e.STATUS_CODE IN (''PROCESSED'',''POSTED'',''PARTIALLY_POSTED'', ''IN_PROCESS''))
                             OR ( '''
                       || p_status_code
                       || ''' = ''REFUNDED'' AND E.INVOICE_AMOUNT = E.REFUND_AMOUNT AND E.INVOICE_AMOUNT >0)
                              OR ( e.STATUS_CODE = '''
                       || p_status_code
                       || ''' AND NVL(REFUND_AMOUNT,0) <> E.INVOICE_AMOUNT) )
                        AND E.ACCOUNT_TYPE IN ('''
                       || v_product_type
                       || ''')
                        AND Trunc(e.INVOICE_DATE) >= NVL('''
                       || trunc(v_from_date)
                       || ''',Trunc(e.INVOICE_DATE)) AND Trunc(e.INVOICE_DATE) <= NVL('''
                       || trunc(v_to_date)
                       || ''',Trunc(e.INVOICE_DATE))';

            v_status_code := 'AND e.STATUS_CODE NOT IN (''VOID'',''DRAFT'')';

         /*
                        AND exists ( SELECT *
                                       FROM RATE_PLAN_DETAIL R
                                      WHERE E.RATE_PLAN_ID = R.RATE_PLAN_ID
                                        AND TRUNC(R.EFFECTIVE_DATE) <= e.END_DATE
                                         AND ( (R.EFFECTIVE_END_DATE IS NULL OR R.EFFECTIVE_END_DATE >= e.END_DATE)
                                             OR ( R.EFFECTIVE_END_DATE IS NOT NULL AND E.END_DATE >=R.EFFECTIVE_END_DATE ))
                                        AND  NVL(e.charged_to,r.charged_to) = '''||P_ENTITY_TYPE||''')  -- Added by Jaggi for 11484 */

        elsif p_flag in ( '3', '4' ) then
            v_sql_2 := 'SELECT outer.*
                       FROM (SELECT ROWNUM rn, inner.*
                       FROM (SELECT  E.INVOICE_NUMBER
                           ,to_char(E.INVOICE_DATE,''dd-mon-yyyy'') INVOICE_DATE
                           ,E.INVOICE_DUE_DATE
                           ,E.STATUS_CODE
                           ,E.STATUS
                           ,E.INVOICE_POSTED_DATE
                           ,E.INVOICE_ID
                           ,E.ENTRP_ID
                           ,E.EMPLOYER_NAME
                           ,E.ACC_ID
                           ,E.ACC_NUM
                           ,E.ACCOUNT_TYPE
                           ,E.INVOICE_TERM
                           ,E.START_DATE
                           ,E.END_DATE
                           ,E.COVERAGE_PERIOD
                           ,E.COMMENTS
                           ,E.AUTO_PAY
                           ,E.BILLING_NAME
                           ,E.BILLING_ADDRESS
                           ,E.BILLING_CITY
                           ,E.BILLING_ZIP
                           ,E.BILLING_STATE
                           ,E.BILLING_ATTN
                           ,E.PAYMENT_METHOD
                           ,E.INVOICE_STATUS
                           ,E.INVOICE_REASON
                           ,E.DIVISION_CODE
                           ,E.REFUND_AMOUNT
                           ,E.INVOICE_AMOUNT
                           ,E.PENDING_AMOUNT
                           ,E.PAID_AMOUNT
                           ,E.VOID_AMOUNT
                           ,E.ENTITY_ID
                           ,E.ENTITY_TYPE
                           ,E.PLAN_TYPE
                           ,E.CREATED_BY
                           ,E.ENROLLE_TYPE
                           ,ROWNUM ROW_NUM
                       FROM UI_INVOICE_QUERY_V e
                      WHERE e.acc_id = NVL('''
                       || v_acc_id
                       || ''',E.ACC_ID)
                        AND E.'
                       || v_entity_id
                       || ' = '
                       || p_entity_id
                       || '
                        AND exists (SELECT  a.*
                                      FROM AR_INVOICE A, ar_invoice_lines ARL, RATE_PLAN_DETAIL R
                                          WHERE A.INVOICE_ID = e.invoice_id
                                           AND A.INVOICE_ID = ARL.INVOICE_ID
                                           AND A.RATE_PLAN_ID = R.RATE_PLAN_ID
                                           AND R.RATE_CODE = ARL.RATE_CODE
                                           AND TRUNC(R.EFFECTIVE_DATE) <= A.END_DATE
                                          -- AND  ( R.EFFECTIVE_END_DATE IS NULL  OR R.EFFECTIVE_END_DATE  >= A.END_DATE)
                                           AND ( (R.EFFECTIVE_END_DATE IS NULL OR R.EFFECTIVE_END_DATE >= e.END_DATE)
                                             OR ( R.EFFECTIVE_END_DATE IS NOT NULL AND E.END_DATE >=R.EFFECTIVE_END_DATE ))
                                           AND  NVL(a.charged_to,r.charged_to) = '''
                       || p_entity_type
                       || ''' )                               
                          AND ( ('''
                       || p_status_code
                       || ''' = ''ALL_STATUS'' AND e.STATUS_CODE IN (''PROCESSED'',''POSTED'',''PARTIALLY_POSTED'', ''IN_PROCESS''))
                             OR ( '''
                       || p_status_code
                       || ''' = ''REFUNDED'' AND E.INVOICE_AMOUNT = E.REFUND_AMOUNT AND E.INVOICE_AMOUNT >0)
                              OR ( e.STATUS_CODE = '''
                       || p_status_code
                       || ''' AND NVL(REFUND_AMOUNT,0) <> E.INVOICE_AMOUNT) )
                        AND E.ACCOUNT_TYPE IN ('''
                       || v_product_type
                       || ''')
                        AND Trunc(e.INVOICE_DATE) >= NVL('''
                       || trunc(v_from_date)
                       || ''',Trunc(e.INVOICE_DATE)) AND Trunc(e.INVOICE_DATE) <= NVL('''
                       || trunc(v_to_date)
                       || ''',Trunc(e.INVOICE_DATE))
                       '
                       || v_order
                       || ' ) inner) outer
                    WHERE outer.rn >= '''
                       || p_start_row
                       || ''' AND outer.rn <= '''
                       || p_end_row
                       || '''';
        end if;

        if p_flag = '1' then
            v_sql := v_sql_1
                     || v_status_code
                     || v_order_clause_1;
        elsif p_flag = '2' then
            v_sql := v_sql_1 || v_order_clause_1;
        elsif p_flag in ( '3', '4' ) then
            v_sql := v_sql_2;
        end if;

        pc_log.log_error('PC_INVOICE.Get_Inv_info_for_broker 7961 :', 'v_sql' || v_sql);
        if p_flag in ( '1', '2' ) then
            open v_sql_cur for v_sql;

            loop
                fetch v_sql_cur into
                    l_record_t.invoice_number,
                    l_record_t.invoice_date,
                    l_record_t.invoice_due_date,
                    l_record_t.status_code,
                    l_record_t.status,
                    l_record_t.invoice_posted_date,
                    l_record_t.invoice_id,
                    l_record_t.entrp_id,
                    l_record_t.employer_name,
                    l_record_t.acc_id,
                    l_record_t.acc_num,
                    l_record_t.account_type,
                    l_record_t.invoice_term,
                    l_record_t.start_date,
                    l_record_t.end_date,
                    l_record_t.coverage_period,
                    l_record_t.comments,
                    l_record_t.auto_pay,
                    l_record_t.billing_name,
                    l_record_t.billing_address,
                    l_record_t.billing_city,
                    l_record_t.billing_zip,
                    l_record_t.billing_state,
                    l_record_t.billing_attn,
                    l_record_t.payment_method,
                    l_record_t.invoice_status,
                    l_record_t.invoice_reason,
                    l_record_t.division_code,
                    l_record_t.refund_amount,
                    l_record_t.invoice_amount,
                    l_record_t.pending_amount,
                    l_record_t.paid_amount,
                    l_record_t.void_amount,
                    l_record_t.entity_id,
                    l_record_t.entity_type,
                    l_record_t.plan_type,
                    l_record_t.created_by         -- Added by Jaggi ##9793
                    ,
                    l_record_t.enrolle_type,
                    l_record_t.rownum_1;

                if l_record_t.enrolle_type <> 'GA' then        -- Added by Jaggi ##9793
                    l_record_t.created_by := null;
                end if;
                exit when v_sql_cur%notfound;
                pipe row ( l_record_t );
            end loop;

            close v_sql_cur;
        elsif p_flag in ( '3', '4' ) then
            open v_sql_cur for v_sql;

            loop
                fetch v_sql_cur into
                    l_record_t.rownum_1,
                    l_record_t.invoice_number,
                    l_record_t.invoice_date,
                    l_record_t.invoice_due_date,
                    l_record_t.status_code,
                    l_record_t.status,
                    l_record_t.invoice_posted_date,
                    l_record_t.invoice_id,
                    l_record_t.entrp_id,
                    l_record_t.employer_name,
                    l_record_t.acc_id,
                    l_record_t.acc_num,
                    l_record_t.account_type,
                    l_record_t.invoice_term,
                    l_record_t.start_date,
                    l_record_t.end_date,
                    l_record_t.coverage_period,
                    l_record_t.comments,
                    l_record_t.auto_pay,
                    l_record_t.billing_name,
                    l_record_t.billing_address,
                    l_record_t.billing_city,
                    l_record_t.billing_zip,
                    l_record_t.billing_state,
                    l_record_t.billing_attn,
                    l_record_t.payment_method,
                    l_record_t.invoice_status,
                    l_record_t.invoice_reason,
                    l_record_t.division_code,
                    l_record_t.refund_amount,
                    l_record_t.invoice_amount,
                    l_record_t.pending_amount,
                    l_record_t.paid_amount,
                    l_record_t.void_amount,
                    l_record_t.entity_id,
                    l_record_t.entity_type,
                    l_record_t.plan_type,
                    l_record_t.created_by         -- Added by Jaggi ##9793
                    ,
                    l_record_t.enrolle_type,
                    l_record_t.rownum_1;

                if l_record_t.enrolle_type <> 'GA' then        -- Added by Jaggi ##9793
                    l_record_t.created_by := null;
                end if;
                exit when v_sql_cur%notfound;
                pipe row ( l_record_t );
            end loop;

            close v_sql_cur;
        end if;

    exception
        when others then
            pc_log.log_error('PC_INVOICE.Get_Inv_info_for_broker 7961 :', 'others' || sqlerrm);
    end get_inv_info_for_broker;

    procedure export_invoice_upload_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) as

        l_file          utl_file.file_type;
        l_buffer        raw(32767);
        l_amount        binary_integer := 32767;
        l_pos           integer := 1;
        l_blob          blob;
        l_blob_len      integer;
        exc_no_file exception;
        l_create_ddl    varchar2(32000);
        lv_dest_file    varchar2(300);
        l_files         samfiles := samfiles();
        l_log_file_name varchar2(2000);
        l_batch_number  number;
        l_file_name     varchar2(300);
    begin

    --  pc_log.log_error('PC_INVOICE.export_invoice_upload_file','pv_file_name: ' || pv_file_name);
        lv_dest_file := substr(pv_file_name,
                               instr(pv_file_name, '/', 1) + 1,
                               length(pv_file_name) - instr(pv_file_name, '/', 1));
    --  pc_log.log_error('PC_INVOICE.export_invoice_upload_file','lv_dest_file: ' || lv_dest_file);

      --l_file_name := 'invoice_upload_new_june.csv';
        l_create_ddl := 'ALTER TABLE INVOICE_EXTERNAL ACCESS PARAMETERS ('
                        || '  records delimited by newline skip 1'
                        || '  badfile '''
                        || lv_dest_file
                        || '.bad'
                        || ''' '
                        || '  logfile '''
                        || lv_dest_file
                        || '.log'
                        || ''' '
                        || '  fields terminated by '','' '
                        || '  optionally enclosed by ''"'' '
                        || '  LRTRIM '
                        || '  MISSING FIELD VALUES ARE NULL)  '
                        || '  LOCATION (INVOICE_UPLOAD_DIR:'''
                        || lv_dest_file
                        || ''')';

      /* Get the contents of BLOB from wwv_flow_files */
        begin
            select
                blob_content
            into l_blob
            from
                wwv_flow_files
            where
                name = pv_file_name;

            pc_log.log_error('PC_INVOICE.export_invoice_upload_file', 'Before opening file');
            l_file := utl_file.fopen('INVOICE_UPLOAD_DIR', lv_dest_file, 'w', 32767);
        -- pc_log.log_error('PC_INVOICE.export_invoice_upload_file','after opening file');

            l_blob_len := dbms_lob.getlength(l_blob); -- gets file length
            while l_pos < l_blob_len loop
                dbms_lob.read(l_blob, l_amount, l_pos, l_buffer);
                utl_file.put_raw(l_file, l_buffer, true);
                l_pos := l_pos + l_amount;
            end loop;
        -- Close the file.
            utl_file.fclose(l_file);

        -- Delete file from wwv_flow_files
            delete from wwv_flow_files
            where
                name = pv_file_name;

        exception
            when others then
                pc_log.log_error('PC_INVOICE.export_invoice_upload_file', 'in reading file : ' || sqlerrm);
        --  NULL;
        end;

        execute immediate l_create_ddl;
        select
            invoice_batch_seq.nextval
        into l_batch_number
        from
            dual;

        x_batch_number := l_batch_number;
        pc_log.log_error('PC_INVOICE.export_invoice_upload_file', 'Batch number: ' || l_batch_number);
        insert into invoice_upload_staging (
            batch_number,
            invoice_upload_id,
            acc_num,
            start_date,
            end_date,
            invoice_date,
            invoice_amount,
            account_type,
            reason_name,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date
        )
            select
                l_batch_number,
                invoice_upload_id_seq.nextval,
                ltrim(rtrim(acc_num)),
                to_char(
                    format_to_date(start_date),
                    'mm/dd/yyyy'
                ),
                to_char(
                    format_to_date(end_date),
                    'mm/dd/yyyy'
                ),
                to_char(
                    format_to_date(invoice_date),
                    'mm/dd/yyyy'
                ),
                replace(invoice_amount, '$', ''),
                account_type,
                ltrim(rtrim(reason_name)),
                p_user_id,
                sysdate,
                p_user_id,
                null
            from
                invoice_external;

        commit;
    exception
        when others then
            rollback;

-- Close the file if something goes wrong.
            if utl_file.is_open(l_file) then
                utl_file.fclose(l_file);
            end if;

-- Delete file from wwv_flows
            delete from wwv_flow_files
            where
                name = pv_file_name;
  /*  mail_utility.send_email('oracle@sterlingadministration.com'
                  ,'techsupport@sterlingadministration.com'
                  ,'Error in Enrollment file Upload'||pv_file_name
                  ,SQLERRM);*/
            pc_file.extract_error_from_log(pv_file_name || '.log', 'INVOICE_UPLOAD_DIR', l_log_file_name);
            l_files.delete;
            l_files.extend(3);
            l_files(1) := '/u01/app/oracle/oradata/invoice_files/' || pv_file_name;
            l_files(2) := '/u01/app/oracle/oradata/invoice_files/'
                          || pv_file_name
                          || '.bad';
            l_files(3) := '/u01/app/oracle/oradata/invoice_files/' || l_log_file_name;
            mail_utility.email_files(
                from_name    => 'enrollments@sterlingadministration.com',
                to_names     => 'it-team@sterlingadministration.com', -- 'techsupport@sterlingadministration.com',
                subject      => 'Error in Enrollment file Upload ' || pv_file_name,
                html_message => sqlerrm,
                attach       => l_files
            );
    --mail_utility.send_email('oracle@sterlingadministration.com','vhsteam@sterlingadministration.com','Error in Enrollment file Upload'||pv_file_name,SQLERRM);

            raise_application_error('-20001', 'Error in Exporting File ' || sqlerrm);
    end export_invoice_upload_file;

    procedure validate_invoice_upload_data (
        p_batch_number in number,
        p_user_id      in number
    ) is

        l_account_t   account_rec_t;
        l_error_count number;
        l_exception_dml_errors exception;
        l_error_desc  varchar2(32000);
        ind           number;
        pragma exception_init ( l_exception_dml_errors, -24381 );
    begin
        pc_log.log_error('PC_INVOICE.validate_invoice_upload_data:p_batch_number: ', p_batch_number);
        select
            iu.invoice_upload_id,
            a.acc_num,
            a.acc_id,
            a.entrp_id,
            null,
            null
        bulk collect
        into l_account_t
        from
            account                a,
            invoice_upload_staging iu
        where
                a.acc_num = iu.acc_num
            and iu.batch_number = p_batch_number;

        begin
            forall i in 1..l_account_t.count save exceptions
                update invoice_upload_staging iu
                set
                    iu.acc_id = l_account_t(i).acc_id,
                    iu.entrp_id = l_account_t(i).entrp_id
                where
                        iu.acc_num = l_account_t(i).acc_num
                    and iu.batch_number = p_batch_number;

        exception
            when l_exception_dml_errors then
                l_error_count := sql%bulk_exceptions.count;
                for ind in 1..l_error_count loop
                    l_error_desc := 'BULK EXCEPTION : Key columns : ID = '
                                    || l_account_t(sql%bulk_exceptions(ind).error_index).invoice_upload_id
                                    || ' : Error message = '
                                    || sqlerrm(-sql%bulk_exceptions(ind).error_code);

                    pc_log.log_error('PC_INVOICE.validate_invoice_upload_data: ', l_error_desc);
                end loop;

        end;

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Account number cannot be blank'
        where
                batch_number = p_batch_number
            and acc_num is null;

  /*
  UPDATE invoice_upload_staging
     SET error_status   = 'E'
        ,error_message  = nvl(error_message,'') ||' Invoice date cannot be blank'
   WHERE batch_number   =  p_batch_number
    -- AND ERROR_MESSAGE IS NULL
     AND invoice_date is null  ;

     UPDATE invoice_upload_staging
     SET error_status   = 'E'
        ,error_message  = nvl(error_message,'') ||' Start date cannot be blank'
   WHERE batch_number   =  p_batch_number
   --  AND ERROR_MESSAGE IS NULL
     AND start_date is null ;

     UPDATE invoice_upload_staging
     SET error_status   = 'E'
        ,error_message  = nvl(error_message,'') ||' End date cannot be blank'
   WHERE batch_number   =  p_batch_number
    --AND ERROR_MESSAGE IS NULL
     AND end_date is null;
     */

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Account type cannot be blank'
        where
                batch_number = p_batch_number
    --AND ERROR_MESSAGE IS NULL
            and account_type is null;

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Invoice amount cannot be blank.'
        where
                batch_number = p_batch_number
            and invoice_amount is null;

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Invoice amount must be numeric value'
        where
                batch_number = p_batch_number
            and error_message is null
            and is_number(invoice_amount) = 'N';

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = 'Account Type should be COBRA. Please enter correct Account Type'
        where
                batch_number = p_batch_number
            and upper(account_type) <> 'COBRA'
            and error_message is null;

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Enter valid value for Invoice Date'
        where
                batch_number = p_batch_number
            and format_to_date(invoice_date) is null
            and error_message is null;

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Enter valid value for Start Date'
        where
                batch_number = p_batch_number
            and format_to_date(start_date) is null
            and error_message is null;

        pc_log.log_error('PC_INVOICE.validate_invoice_upload_data: ', 'before end date validation');
        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Enter valid value for End Date'
        where
                batch_number = p_batch_number
            and format_to_date(end_date) is null
            and error_message is null;

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Invoice Date must be equal to todays date'
        where
                batch_number = p_batch_number
            and format_to_date(invoice_date) not between trunc(sysdate) and trunc(sysdate) + 1
            and error_message is null;

        pc_log.log_error('PC_INVOICE.validate_invoice_upload_data: ', 'after end date validation');
        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Account number do not exist.'
        where
                batch_number = p_batch_number
            and acc_id is null
            and error_message is null;

        update invoice_upload_staging iu
        set
            iu.error_status = 'E',
            iu.error_message = nvl(error_message, ' ')
                               || 'Account number should be of COBRA Account type, Please enter correct Account No'
        where
                iu.batch_number = p_batch_number
            and iu.acc_id is not null
            and error_message is null
            and exists (
                select
                    *
                from
                    account
                where
                        acc_id = iu.acc_id
                    and account_type <> 'COBRA'
            );

        update invoice_upload_staging iu
        set
            iu.rate_code = (
                select
                    p.reason_code
                from
                    pay_reason p
                where
                    lower(reason_name) = lower(iu.reason_name)
            )
        where
            iu.batch_number = p_batch_number;

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, ' ')
                            || 'Reason name is not valid or reason name is not entered'
        where
                batch_number = p_batch_number
            and rate_code is null
            and error_message is null;

        update invoice_upload_staging iu
        set
            iu.error_status = 'E',
            iu.error_message = nvl(iu.error_message, ' ')
                               || 'Reason name is not part of COBRA Subsidy Fee reasons'
        where
                batch_number = p_batch_number
            and rate_code is not null
            and error_message is null
            and not exists (
                select
                    rpd.rate_code
                from
                    rate_plans       rp,
                    rate_plan_detail rpd
                where
                        rp.rate_plan_id = rpd.rate_plan_id
                    and rp.rate_plan_name = 'COBRA_SUBSIDY_FEES'
                    and rpd.rate_code = iu.rate_code
            );

        update invoice_upload_staging iu
        set
            iu.error_status = 'E',
            iu.error_message = nvl(error_message, ' ')
                               || 'Invoice is already generated for this'
        where
                batch_number = p_batch_number
            and error_message is null
            and exists (
                select
                    *
                from
                    ar_invoice       ar,
                    ar_invoice_lines arl
                where
                        ar.entity_id = iu.entrp_id
                    and ar.entity_type = 'EMPLOYER'
                    and ar.invoice_id = arl.invoice_id
                    and arl.rate_code = iu.rate_code
                    and ar.status = 'GENERATED'
            );

        select
            iu.invoice_upload_id,
            iu.acc_num,
            iu.acc_id,
            iu.entrp_id,
            c.rate_plan_id,
            a.bank_acct_id
        bulk collect
        into l_account_t
        from
            invoice_parameters     a,
            invoice_upload_staging iu,
            rate_plans             c
        where
                iu.batch_number = p_batch_number
            and a.entity_id = iu.entrp_id
            and a.entity_type = 'EMPLOYER'
            and nvl(iu.error_status, 'S') = 'S'
            and c.entity_id = a.entity_id
            and a.rate_plan_id = c.rate_plan_id
            and c.status = 'A'
            and a.status = 'A'
            and a.invoice_type = 'FEE'
            and c.division_code is null
            and a.division_code is null
            and c.rate_plan_type = 'INVOICE'
            and trunc(c.effective_date) <= to_date(iu.end_date, 'MM/DD/YYYY')
            and ( c.effective_end_date is null
                  or c.effective_end_date >= to_date(iu.end_date, 'MM/DD/YYYY')
                  or c.effective_end_date between to_date(iu.start_date, 'MM/DD/YYYY') and to_date(iu.end_date, 'MM/DD/YYYY') )
            and a.invoice_frequency <> 'QUARTERLY'
            and nvl(c.division_invoicing, 'N') = 'N';

        begin
            forall i in 1..l_account_t.count save exceptions
                update invoice_upload_staging iu
                set
                    iu.rate_plan_id = l_account_t(i).rate_plan_id,
                    iu.bank_acct_id = l_account_t(i).bank_acct_id
                where
                        iu.acc_id = l_account_t(i).acc_id
                    and iu.batch_number = p_batch_number;

        exception
            when l_exception_dml_errors then
                l_error_count := sql%bulk_exceptions.count;
                for ind in 1..l_error_count loop
                    l_error_desc := 'BULK EXCEPTION : Key columns : ID = '
                                    || l_account_t(sql%bulk_exceptions(ind).error_index).invoice_upload_id
                                    || ' : Error message = '
                                    || sqlerrm(-sql%bulk_exceptions(ind).error_code);

                    pc_log.log_error('PC_INVOICE.validate_invoice_upload_data(rate plan update): ', l_error_desc);
                end loop;

        end;

        update invoice_upload_staging
        set
            error_status = 'E',
            error_message = nvl(error_message, '')
                            || ' Invoice setup is not done for this account for FEE invoice type'
        where
                batch_number = p_batch_number
            and rate_plan_id is null
            and error_message is null;

    exception
        when others then
            pc_log.log_error('PC_INVOICE.validate invoice', sqlerrm);
            raise_application_error('-20001', 'Error in validating the invoice upload data: ' || sqlerrm);
    end validate_invoice_upload_data;

    procedure process_invoice_upload_file (
        pv_file_name   in varchar2,
        p_user_id      in number,
        x_batch_number out number
    ) is
        l_batch_number  number;
        l_return_status varchar2(1);
        l_error_message varchar2(32000);
    begin
        export_invoice_upload_file(pv_file_name, p_user_id, l_batch_number);
        validate_invoice_upload_data(l_batch_number, p_user_id);
        process_invoices(l_batch_number, l_return_status, l_error_message);
        x_batch_number := l_batch_number;
        commit;
    end process_invoice_upload_file;

    procedure process_invoices (
        p_batch_number  in number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_invoice_upload_tab invoice_upload_rec_t;
        type invoice_id_t is
            table of ar_invoice.invoice_id%type;
        l_invoice_id         number;
        l_invoice_line_id    number;
        l_return_status      varchar2(1);
        l_error_message      varchar2(32000);
    begin
        pc_log.log_error('PC_INVOICE.process_invoices', 'p_batch_number: ' || p_batch_number);
        select
            iu.acc_id,
            iu.acc_num,
            iu.account_type,
            iu.entrp_id,
            iu.rate_plan_id,
            ip.invoice_param_id,
            iu.rate_code,
            iu.reason_name,
            iu.bank_acct_id,
            to_date(iu.invoice_date, 'mm/dd/yyyy'),
            to_date(iu.start_date, 'mm/dd/yyyy'),
            to_date(iu.end_date, 'mm/dd/yyyy'),
            iu.invoice_amount,
            iu.invoice_type,
            ip.payment_term,
            ip.payment_method,
            ip.billing_name,
            ip.billing_attn,
            ip.billing_address,
            ip.billing_city,
            ip.billing_zip,
            ip.billing_state,
            iu.created_by,
            iu.invoice_upload_id,
            iu.error_status,
            iu.error_message,
            ip.last_invoiced_date
        bulk collect
        into l_invoice_upload_tab
        from
            invoice_upload_staging iu,
            invoice_parameters     ip
        where
                iu.batch_number = p_batch_number
            and iu.rate_plan_id = ip.rate_plan_id
            and ip.status = 'A'
            and ip.invoice_type = 'FEE'
            and iu.error_status is null
            and iu.rate_code is not null;

        pc_log.log_error('PC_INVOICE.process_invoices', 'L_INVOICE_UPLOAD_TAB.count: ' || l_invoice_upload_tab.count);
        for i in 1..l_invoice_upload_tab.count  --  l_invoice_upload_tab.first .. l_invoice_upload_tab.last
         loop
            pc_log.log_error('PC_INVOICE.process_invoices', ' inside for loop' || l_invoice_upload_tab.count);
            pc_invoice.insert_rate_detail(
                l_invoice_upload_tab(i),
                l_return_status,
                l_error_message
            );
            if l_return_status = 'S' then
                pc_invoice.insert_ar_invoice(
                    p_start_date     => l_invoice_upload_tab(i).start_date,
                    p_end_date       => l_invoice_upload_tab(i).end_date,
                    p_billing_date   => l_invoice_upload_tab(i).invoice_date,
                    p_entrp_id       => l_invoice_upload_tab(i).entrp_id,
                    p_product_type   => l_invoice_upload_tab(i).account_type,
                    p_batch_number   => p_batch_number,
                    p_invoice_reason => l_invoice_upload_tab(i).invoice_type,
                    x_invoice_id     => l_invoice_id,
                    p_division_code  => null
                );
            end if;

            pc_log.log_error('PC_INVOICE.process_invoices', ' l_invoice_id: ' || l_invoice_id);
            if l_invoice_id is not null then
                pc_invoice.insert_invoice_line(
                    p_invoice_id        => l_invoice_id,
                    p_invoice_line_type => 'FLAT_FEE',
                    p_rate_code         => l_invoice_upload_tab(i).rate_code,
                    p_description       => l_invoice_upload_tab(i).reason_name,
                    p_quantity          => 1,
                    p_no_of_months      => 1,
                    p_rate_cost         => l_invoice_upload_tab(i).invoice_amount,
                    p_total_cost        => l_invoice_upload_tab(i).invoice_amount,
                    p_batch_number      => p_batch_number,
                    x_invoice_line_id   => l_invoice_line_id
                );
            end if;

            if l_invoice_line_id is not null then
                update invoice_upload_staging
                set
                    error_status = 'S',
                    error_message = 'Invoice generated successfully.',
                    invoice_id = l_invoice_id
                where
                        batch_number = p_batch_number
                    and invoice_upload_id = l_invoice_upload_tab(i).invoice_upload_id;

                update rate_plan_detail
                set
                    effective_end_date = l_invoice_upload_tab(i).invoice_date,
                    last_update_date = sysdate
                where
                        rate_code = l_invoice_upload_tab(i).rate_code
                    and rate_plan_id = l_invoice_upload_tab(i).rate_plan_id
                    and one_time_flag = 'Y'
                    and effective_end_date is null;

                update ar_invoice
                set
                    status = 'GENERATED',
                    invoice_date = l_invoice_upload_tab(i).invoice_date,
                    billing_date = l_invoice_upload_tab(i).invoice_date,
                    invoice_due_date = l_invoice_upload_tab(i).invoice_date + decode(invoice_term,
                                                                                     'NET7',
                                                                                     7,
                                                                                     'NET60',
                                                                                     60,
                                                                                     'NET30',
                                                                                     30,
                                                                                     'NET15',
                                                                                     15,
                                                                                     'NET90',
                                                                                     90,
                                                                                     'PIA',
                                                                                     1,
                                                                                     'IMMEDIATE',
                                                                                     5,
                                                                                     round(add_bus_days(sysdate, 4) - sysdate)),
                    invoice_amount = l_invoice_upload_tab(i).invoice_amount,
                    pending_amount = l_invoice_upload_tab(i).invoice_amount,
                    last_invoiced_date = l_invoice_upload_tab(i).last_invoiced_date,
                    last_update_date = sysdate,
                    last_updated_by = l_invoice_upload_tab(i).created_by
                where
                    invoice_id = l_invoice_id;

                update ar_invoice_lines
                set
                    status = 'GENERATED',
                    last_update_date = sysdate,
                    last_updated_by = l_invoice_upload_tab(i).created_by
                where
                    invoice_id = l_invoice_id;

                update invoice_parameters
                set
                    last_invoiced_date = l_invoice_upload_tab(i).invoice_date
                where
                        entity_id = l_invoice_upload_tab(i).entrp_id
                    and entity_type = 'EMPLOYER'
                    and invoice_type = l_invoice_upload_tab(i).invoice_type
                    and rate_plan_id = l_invoice_upload_tab(i).rate_plan_id;

            end if;

        end loop;

        pc_log.log_error('PC_INVOICE.process_invoices', 'before delete statement');
        if l_invoice_upload_tab.count > 0 then
            delete from ar_invoice
            where
                not exists (
                    select
                        *
                    from
                        ar_invoice_lines
                    where
                        invoice_id = ar_invoice.invoice_id
                )
                    and status = 'DRAFT'
                    and trunc(creation_date) = trunc(sysdate)
                    and batch_number = p_batch_number;

        end if;

        x_error_status := 'S';
        pc_log.log_error('PC_INVOICE.process_invoices:x_error_status', x_error_status);
    exception
        when others then
            x_error_status := 'E';
            x_error_message := nvl(l_error_message,
                                   substr(sqlerrm, 1, 200));
            pc_log.log_error('PC_INVOICE.process_invoices',
                             'Error message '
                             || nvl(l_error_message,
                                    substr(sqlerrm, 1, 200)));

            raise;
            rollback;
    end process_invoices;

    procedure insert_rate_detail (
        p_invoice_upload_tab invoice_upload_rec,
        x_error_status       out varchar2,
        x_error_message      out varchar2
    ) is
        l_rate_plan_detail_count number := 0;
    begin
        select
            count(*)
        into l_rate_plan_detail_count
        from
            rate_plan_detail
        where
                rate_plan_id = p_invoice_upload_tab.rate_plan_id
            and rate_code = p_invoice_upload_tab.rate_code
            and effective_date = p_invoice_upload_tab.invoice_date;

        if l_rate_plan_detail_count = 0 then
            insert into rate_plan_detail (
                rate_plan_detail_id,
                rate_plan_id,
                coverage_type,
                calculation_type,
                minimum_range,
                maximum_range,
                description,
                rate_code,
                rate_plan_cost,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                rate_basis,
                effective_date,
                one_time_flag,
                invoice_param_id
            ) values ( rate_plan_detail_seq.nextval,
                       p_invoice_upload_tab.rate_plan_id,
                       null,
                       'AMOUNT',
                       null,
                       null,
                       p_invoice_upload_tab.reason_name,
                       p_invoice_upload_tab.rate_code,
                       p_invoice_upload_tab.invoice_amount,
                       sysdate,
                       p_invoice_upload_tab.created_by,
                       sysdate,
                       p_invoice_upload_tab.created_by,
                       'FLAT_FEE',
                       p_invoice_upload_tab.invoice_date,
                       'Y',
                       p_invoice_upload_tab.invoice_param_id );

        end if;

        x_error_status := 'S';
    exception
        when others then
            x_error_status := 'E';
            x_error_message := substr(sqlerrm, 1, 3200);
            pc_log.log_error('PC_INVOICE.INSERT_RATE_DETAIL',
                             'Error message '
                             || substr(sqlerrm, 1, 3200));

            rollback;
    end insert_rate_detail;

-- Skeleton procedure to create skeleton invoice
-- Called from APEX to create manual invoice
-- Also used for creating claim invoice/funding invoice
    procedure insert_premium_invoice (
        p_start_date     in date,
        p_end_date       in date,
        p_billing_date   in date default sysdate,
        p_due_date       in date default sysdate,
        p_pers_id        in number,
        p_product_type   in varchar2 default 'COBRA',
        p_batch_number   in number,
        p_invoice_reason in varchar2 default 'PREMIUM',
        x_invoice_id     out number,
        p_division_code  in varchar2 default null
    ) is
        l_invoice_id number;
    begin
        pc_log.log_error('insert_ar_invoice', 'PERS_ID ' || p_pers_id);
        pc_log.log_error('insert_ar_invoice', 'P_START_DATE ' || p_start_date);
        pc_log.log_error('insert_ar_invoice', 'P_END_DATE ' || p_end_date);
        pc_log.log_error('insert_ar_invoice', 'P_PRODUCT_TYPE ' || p_product_type);
        select
            ar_invoice_seq.nextval
        into l_invoice_id
        from
            dual;

        insert into ar_invoice (
            invoice_id,
            invoice_number,
            invoice_date,
            billing_date,
            invoice_due_date,
            invoice_type,
            invoice_reason,
            invoice_amount,
            pending_amount,
            acc_id,
            acc_num,
            entity_id,
            entity_type,
            invoice_term,
            auto_pay,
            rate_plan_id,
            payment_method,
            batch_number,
            status,
            last_invoiced_date,
            start_date,
            end_date,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            bank_acct_id,
            billing_name,
            billing_attn,
            billing_address,
            billing_city,
            billing_zip,
            billing_state,
            division_code,
            plan_type
        )
            select
                l_invoice_id,
                invoice_number_seq.nextval,
                sysdate        invoice_date,
                sysdate + 1    billing_date,
                p_due_date,
                'AUTO',
                p_invoice_reason,
                0,
                0,
                b.acc_id,
                b.acc_num,
                b.pers_id,
                'PERSON',
                a.payment_term,
                a.autopay,
                c.rate_plan_id,
                a.payment_method,
                p_batch_number,
                'DRAFT',
                a.last_invoiced_date,
                p_start_date,
                p_end_date,
                0,
                sysdate,
                0,
                sysdate,
                a.bank_acct_id,
                p.first_name
                || ' '
                || p.last_name billing_name,
                p.first_name
                || ' '
                || p.last_name,
                p.address
                || ' '
                || p.address2,
                p.city,
                p.zip,
                p.state,
                p.division_code,
                b.account_type
            from
                invoice_parameters a,
                account            b,
                rate_plans         c,
                person             p
            where
                    p.pers_id = p_pers_id
                and b.pers_id = p.pers_id
                and a.entity_id = b.pers_id
                and a.entity_type = 'PERSON'
                and c.entity_id = a.entity_id
                and c.rate_plan_id = a.rate_plan_id
                and c.entity_type = a.entity_type
                and c.status = 'A'
                and a.status = 'A'
                and a.invoice_type = p_invoice_reason
                and ( a.product_type is null
                      or a.product_type = p_product_type )
                and nvl(a.division_code, '-1') = nvl(c.division_code, '-1')
                and nvl(c.division_code, '-1') = nvl(p_division_code,
                                                     nvl(c.division_code, '-1'))
                and c.rate_plan_type = 'PREMIUM'
                and trunc(c.effective_date) <= p_end_date
                and ( c.effective_end_date is null
                      or c.effective_end_date >= p_end_date );

        if sql%rowcount > 0 then
            x_invoice_id := l_invoice_id;
        end if;
        pc_log.log_error('insert_ar_invoice', 'X_INVOICE_ID ' || x_invoice_id);
    end insert_premium_invoice;

    procedure process_cobra_premium (
        p_start_date    in date,
        p_end_date      in date,
        p_billing_date  in date default sysdate,
        p_due_date      in date default sysdate,
        p_product_type  in varchar2,
        p_pers_id       in number,
        p_batch_number  in number,
        x_invoice_id    out number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is

        l_exists           varchar2(1) := 'N';
        invoice_exception exception;
        no_invoice exception;
        l_return_status    varchar2(1);
        l_error_message    varchar2(32000);
        l_rate             number;
        l_quantity         number;
    --l_invoice_days    number;
   -- l_total           number;
        l_line_type        varchar2(50);
        l_fee_count        number := 0;
        l_inv_count        number := 0;
        l_invoice_id       number;
        l_invoice_line_id  number;
        l_total_inv_amount number := 0;
        l_pers_id          number;
        l_pers_tbl         number_table;
        l_prev_line_amount number := 0;
        i                  number := 0;
        l_no_of_months     number := 0;
        l_plan_code        number; /*Ticket* 7391 */
        l_plan_cost        number;
    begin
        x_error_status := 'S';

   /*  SELECT COUNT(*) INTO l_inv_count
     FROM ar_invoice
     WHERE   invoice_reason = 'PREMIUM'
     AND     entity_id = p_pers_id
     AND     entity_type = 'PERSON'
     AND STATUS IN ('GENERATED','PROCESSED');
     IF l_inv_count > 0 THEN
        RAISE INVOICE_EXCEPTION;
     ELSE */
        insert_premium_invoice(p_start_date, p_end_date, p_billing_date, p_due_date, p_pers_id,
                               p_product_type, p_batch_number, 'PREMIUM', l_invoice_id, null);

        pc_log.log_error('generate_premium_invoice  ', 'INVOICE_ID ' || l_invoice_id);
    -- END IF;
        if l_invoice_id is null then
            raise no_invoice;
        else
            pc_log.log_error('generate_premium_invoice  ', 'in else');
            for x in (
                select
                    a.invoice_id,
                    b.rate_code,
                    case
                        when to_char(p_start_date, 'DD') <> '01' then
                            round((b.rate_plan_cost /(p_end_date -(trunc(p_start_date, 'MM')) + 1)) *((p_end_date - p_start_date) + 1
                            ),
                                  2)
                        else
                            b.rate_plan_cost
                    end           rate_plan_cost,
                    b.rate_basis,
                    b.rate_plan_id,
                    b.calculation_type,
                    a.entity_id,
                    a.plan_type,
                    a.invoice_date,
                    a.last_invoiced_date,
                    c.reason_name rate_description,
                    a.batch_number,
                    b.rate_plan_detail_id
                from
                    ar_invoice         a,
                    rate_plan_detail   b,
                    invoice_parameters d   --FSA Funding
                    ,
                    pay_reason         c
                where
                        a.invoice_id = l_invoice_id
                    and a.rate_plan_id = b.rate_plan_id
                    and d.rate_plan_id = b.rate_plan_id
                    and d.invoice_param_id = b.invoice_param_id
                    and trunc(b.effective_date) <= p_start_date
                    and ( b.effective_end_date is null
                          or b.effective_end_date >= p_end_date ) --It will be end dated by pgm not by user
                    and a.status = 'DRAFT'
                    and d.status = 'A'
                    and a.entity_type = 'PERSON'
                    and b.rate_code = to_char(c.reason_code)
                    and d.entity_id = a.entity_id
                    and b.calculation_type = 'AMOUNT'
                    and c.reason_type <> 'PREMIUM_SUBSIDY'
                    and d.invoice_type = a.invoice_reason
            )  -- PREMIUM
             loop
                pc_log.log_error('generate_premium_invoice  ', 'in else 1');
                l_prev_line_amount := 0;
                for xx in (
                    select
                        arl.total_line_amount
                    from
                        ar_invoice_lines arl,
                        ar_invoice       i
                    where
                            i.entity_id = x.entity_id
                        and i.invoice_id = arl.invoice_id
                        and i.status in ( 'POSTED', 'GENERATED', 'PROCESSED' )
                        and arl.invoice_line_type = x.rate_basis
                        and arl.rate_code = x.rate_code
                        and i.start_date = p_start_date
                        and i.end_date = p_end_date
                ) loop
                    pc_log.log_error('generate_premium_invoice  ', 'in else 2');
                    l_prev_line_amount := xx.total_line_amount;
                end loop;

                if x.rate_plan_cost - nvl(l_prev_line_amount, 0) > 0 then
                    pc_log.log_error('generate_premium_invoice  ', 'in else 3');
                    pc_invoice.insert_invoice_line(
                        p_invoice_id          => x.invoice_id,
                        p_invoice_line_type   => x.rate_basis,
                        p_rate_code           => x.rate_code,
                        p_description         => x.rate_description,
                        p_quantity            => 1,
                        p_no_of_months        => 1,
                        p_rate_cost           => x.rate_plan_cost - nvl(l_prev_line_amount, 0),
                        p_total_cost          => x.rate_plan_cost - nvl(l_prev_line_amount, 0),
                        p_batch_number        => x.batch_number,
                        x_invoice_line_id     => l_invoice_line_id,
                        p_rate_plan_detail_id => x.rate_plan_detail_id
                    );

                end if;

            end loop;
       -- PROCESS SUBSIDIES
            for x in (
                select
                    a.invoice_id,
                    b.rate_code,
                    case
                        when b.calculation_type = 'PERCENTAGE' then
                            arl.total_line_amount * ( nvl(b.rate, 0) / 100 )
                        else
                            nvl(b.rate, 0)
                    end            rate_plan_cost,
                    pe.c_plan_name rate_basis,
                    b.rate_plan_id,
                    b.calculation_type,
                    a.entity_id,
                    a.plan_type,
                    a.invoice_date,
                    a.last_invoiced_date,
                    c.reason_name  rate_description,
                    a.batch_number,
                    rp.rate_plan_detail_id
                from
                    ar_invoice       a,
                    subsidy_schedule b,
                    rate_plan_detail rp,
                    plan_elections   pe
               --  ,   INVOICE_PARAMETERS D
                    ,
                    pay_reason       c,
                    ar_invoice_lines arl
                where
                        a.invoice_id = l_invoice_id
                    and a.invoice_id = arl.invoice_id
                    and arl.rate_code in ( '91', '92' )
                    and rp.rate_code in ( '91', '92' )
                    and a.rate_plan_id = b.rate_plan_id
           --   AND    D.RATE_PLAN_ID = B.RATE_PLAN_ID
                    and rp.rate_plan_id = b.rate_plan_id
         --     AND    D.INVOICE_PARAM_ID = B.INVOICE_PARAM_ID
                    and arl.rate_plan_detail_id = rp.rate_plan_detail_id
                    and rp.plan_id = pe.plan_election_id
                    and pe.c_plan_type = b.plan_type
                    and trunc(b.effective_date) <= p_start_date
                    and ( b.effective_end_date is null
                          or b.effective_end_date >= p_end_date ) --It will be end dated by pgm not by user
                    and a.status = 'DRAFT'
             -- AND    D.STATUS = 'A'
                    and a.entity_type = 'PERSON'
                    and b.rate_code = to_char(c.reason_code)
                    and b.rate_code = 93
                    and b.pers_id = a.entity_id
              --AND    B.CALCULATION_TYPE in  ('AMOUNT','PERCENTAGE')
                    and b.calculation_type = 'PERCENTAGE'
                    and c.reason_type = 'PREMIUM_SUBSIDY'
                    and a.invoice_reason = 'PREMIUM'
            )  -- PREMIUM
             loop
                pc_log.log_error('generate_premium_invoice  ', 'in else 4');
                pc_invoice.insert_invoice_line(
                    p_invoice_id          => x.invoice_id,
                    p_invoice_line_type   => x.rate_basis,
                    p_rate_code           => x.rate_code,
                    p_description         => 'Subsidy Payment for ' || x.rate_description,
                    p_quantity            => 1,
                    p_no_of_months        => 1,
                    p_rate_cost           => x.rate_plan_cost,
                    p_total_cost          => x.rate_plan_cost,
                    p_batch_number        => x.batch_number,
                    x_invoice_line_id     => l_invoice_line_id,
                    p_rate_plan_detail_id => x.rate_plan_detail_id
                );

            end loop;

            for x in (
                select
                    a.invoice_id,
                    b.rate_code,
                    least(arl.total_line_amount - nvl(b.rate, 0),
                          nvl(b.rate, 0)) rate_plan_cost,
                    pe.c_plan_name        rate_basis,
                    b.rate_plan_id,
                    b.calculation_type,
                    a.entity_id,
                    a.plan_type,
                    a.invoice_date,
                    a.last_invoiced_date,
                    c.reason_name         rate_description,
                    a.batch_number,
                    rp.rate_plan_detail_id
                from
                    ar_invoice       a,
                    subsidy_schedule b,
                    rate_plan_detail rp,
                    plan_elections   pe
               --  ,   INVOICE_PARAMETERS D
                    ,
                    pay_reason       c,
                    ar_invoice_lines arl
                where
                        a.invoice_id = l_invoice_id
                    and a.invoice_id = arl.invoice_id
                    and arl.rate_code = '91'
                    and rp.rate_code = '91'
                    and a.rate_plan_id = b.rate_plan_id
           --   AND    D.RATE_PLAN_ID = B.RATE_PLAN_ID
                    and rp.rate_plan_id = b.rate_plan_id
         --     AND    D.INVOICE_PARAM_ID = B.INVOICE_PARAM_ID
                    and arl.rate_plan_detail_id = rp.rate_plan_detail_id
                    and rp.plan_id = pe.plan_election_id
                    and pe.c_plan_type = b.plan_type
                    and trunc(b.effective_date) <= p_start_date
                    and ( b.effective_end_date is null
                          or b.effective_end_date >= p_end_date ) --It will be end dated by pgm not by user
                    and a.status = 'DRAFT'
             -- AND    D.STATUS = 'A'
                    and a.entity_type = 'PERSON'
                    and b.rate_code = to_char(c.reason_code)
                    and b.rate_code = 93
                    and b.pers_id = a.entity_id
                    and b.calculation_type = 'AMOUNT'
                    and c.reason_type = 'PREMIUM_SUBSIDY'
                    and a.invoice_reason = 'PREMIUM'
            )  -- PREMIUM
             loop
                pc_log.log_error('generate_premium_invoice  ', 'in else 5');
                pc_invoice.insert_invoice_line(
                    p_invoice_id          => x.invoice_id,
                    p_invoice_line_type   => x.rate_basis,
                    p_rate_code           => x.rate_code,
                    p_description         => 'Subsidy Payment for ' || x.rate_description,
                    p_quantity            => 1,
                    p_no_of_months        => 1,
                    p_rate_cost           => x.rate_plan_cost,
                    p_total_cost          => x.rate_plan_cost,
                    p_batch_number        => x.batch_number,
                    x_invoice_line_id     => l_invoice_line_id,
                    p_rate_plan_detail_id => x.rate_plan_detail_id
                );

            end loop;

            for x in (
                select
                    ar.invoice_id,
                    ar.invoice_date,
                    ar.entity_id,
                    ar.entity_type,
                    ar.billing_date,
                    a.invoice_type,
                    sum(arl.total_line_amount) invoice_amount,
                    a.rate_plan_id,
                    a.autopay,
                    ar.bank_acct_id
                from
                    ar_invoice         ar,
                    ar_invoice_lines   arl,
                    invoice_parameters a,
                    pay_reason         pr
                where
                        ar.invoice_id = l_invoice_id
                    and ar.invoice_id = arl.invoice_id
                    and a.entity_id = ar.entity_id
                    and a.rate_plan_id = ar.rate_plan_id
                    and arl.rate_code = to_char(pr.reason_code)
                    and ar.invoice_reason = a.invoice_type
                    and ar.payment_method = a.payment_method  /*Ticket#7391 */
                    and ar.status = 'DRAFT'
                    and a.status = 'A'
                    and arl.status = 'DRAFT'
                group by
                    ar.invoice_id,
                    ar.invoice_date,
                    ar.entity_id,
                    ar.entity_type,
                    ar.billing_date,
                    a.invoice_type,
                    a.rate_plan_id,
                    a.autopay,
                    ar.bank_acct_id
                order by
                    1
            ) loop
                pc_log.log_error('generate_premium_invoice  ', 'in else 6');
                update ar_invoice
                set
                    status =
                        case
                            when x.autopay = 'Y' then
                                'GENERATED'
                            else
                                'PROCESSED'
                        end,
                    invoice_amount = x.invoice_amount,
                    pending_amount = x.invoice_amount,
                    invoice_date = start_date,
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                    invoice_id = x.invoice_id;

                update ar_invoice_lines
                set
                    status =
                        case
                            when x.autopay = 'Y' then
                                'GENERATED'
                            else
                                'PROCESSED'
                        end,
                    last_update_date = sysdate,
                    last_updated_by = 0
                where
                    invoice_id = x.invoice_id;

                        -- set last invoiced date
                update invoice_parameters
                set
                    last_invoiced_date = x.billing_date
                where
                        entity_id = x.entity_id
                    and entity_type = 'PERSON'
                    and invoice_type = x.invoice_type
                    and rate_plan_id = x.rate_plan_id;

                      --   IF X.AUTOPAY = 'Y' AND X.BANK_ACCT_ID IS NOT NULL THEN
                      --      PC_INVOICE.RETRY_ACH( X.INVOICE_ID ,0);
                      --   END IF;

            end loop;

        end if;

        x_invoice_id := l_invoice_id;
    exception
        when invoice_exception then
            x_error_status := 'E';
            x_error_message := 'There is already unpaid premium invoice, new invoice will not be created';
        when no_invoice then
            x_error_status := 'E';
            x_error_message := 'Error in creating premium invoice, Verify the setup';
    end process_cobra_premium;

    procedure post_premium (
        p_transaction_id in number,
        p_invoice_id     in number
    ) is
        l_pers_id number;
    begin
 ---- 19/01/2024 rprabu enrollment Confirmation  
        begin
            if p_invoice_id is not null then
                select
                    entity_id
                into l_pers_id
                from
                    ar_invoice
                where
                        invoice_id = p_invoice_id
                    and entity_type = 'PERSON';

                pc_log.log_error('PC_INVOICE.post_premium', '  L_pers_id ' || l_pers_id);
            end if;
        exception
            when no_data_found then
                l_pers_id := null;
        end;

        if l_pers_id is not null then   ----  If added on 19/01/2024 rprabu enrollment Confirmation  
            insert into income (
                change_num,
                acc_id,
                fee_date,
                fee_code,
                amount,
                pay_code,
                cc_number,
                note,
                amount_add,
                ee_fee_amount,
                list_bill,
                transaction_type,
                due_date
            )
                select
                    change_seq.nextval,
                    acc_id,
                    transaction_date,
                    92,
                    0,
                    pay_code,
                    decode(pay_code, 3, 'ACH' || transaction_id, 'CNB' || transaction_id),
                    'Premium posted on '
                    || sysdate
                    || ' for '
                    || to_char(start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(end_date, 'MM/DD/YYYY'),
                    case
                        when nvl(amount, 0) + nvl(subsidy, 0) < 0 then
                            nvl(amount, 0)
                        else
                            nvl(amount, 0) + nvl(subsidy, 0)
                    end,
                    case
                        when nvl(amount, 0) + nvl(subsidy, 0) < 0 then
                            nvl(fee_amount, 0) - ( nvl(amount, 0) + nvl(subsidy, 0) )
                        else
                            nvl(fee_amount, 0)
                    end,
                    invoice_id,
                    'I',
                    start_date
                from
                    (
                        select
                            a.acc_id,
                            transaction_date,
                            reason_code,
                            a.pay_code,
                            a.transaction_id,
                            a.invoice_id,
                            sum(
                                case
                                    when il.rate_code = 91 then
                                        il.total_line_amount
                                    else
                                        0
                                end
                            ) amount,
                            sum(
                                case
                                    when il.rate_code = 92 then
                                        il.total_line_amount
                                    else
                                        0
                                end
                            ) fee_amount,
                            sum(
                                case
                                    when il.rate_code = 93 then
                                        il.total_line_amount
                                    else
                                        0
                                end
                            ) subsidy,
                            i.start_date,
                            i.end_date
                        from
                            ach_transfer_v   a,
                            ar_invoice       i,
                            ar_invoice_lines il
                        where
                                i.invoice_id = a.invoice_id
                            and i.invoice_reason = 'PREMIUM'
                            and i.entity_type = 'PERSON'
                            and i.entity_id = a.pers_id
                            and a.entrp_id is null
                            and transaction_type = 'C'
                            and il.status not in ( 'VOID', 'CANCELLED' )
                            and a.status = 3
                            and i.invoice_id = il.invoice_id
                            and upper(bankserv_status) = 'APPROVED'
                            and trunc(transaction_date) <= trunc(sysdate + 1)
                            and a.pers_id is not null
                            and a.transaction_id = p_transaction_id
                            and not exists (
                                select
                                    *
                                from
                                    income
                                where
                                        income.acc_id = a.acc_id
                                    and list_bill = i.invoice_id
                                    and fee_date = a.transaction_date
                            )
                        group by
                            a.acc_id,
                            transaction_date,
                            reason_code,
                            a.pay_code,
                            a.transaction_id,
                            a.invoice_id,
                            i.start_date,
                            i.end_date
                    );

            update ar_invoice_lines
            set
                status = 'POSTED'
            where
                    invoice_id = p_invoice_id
                and status = 'IN_PROCESS';

            update ar_invoice
            set
                status = 'POSTED',
                pending_amount = 0--, posted_amount = invoice_amount
                ,
                paid_amount = (
                    select
                        sum(total_line_amount)
                    from
                        ar_invoice_lines l
                    where
                            l.invoice_id = ar_invoice.invoice_id
                        and status not in ( 'VOID', 'CANCELLED' )
                ),
                invoice_posted_date = sysdate,
                last_update_date = sysdate,
                last_updated_by = 0
            where
                    invoice_id = p_invoice_id
                and status = 'IN_PROCESS';

            pc_log.log_error('PC_INVOICE.post_premium', '  POSTED ' || p_invoice_id);     
				----------- Email for cobra Enrollment rprabu 19/01/2024
			--	PC_COBRA_NOTIFICATIONS.COBRA_ENROLLEMENT_NOTIFICATION( L_pers_id ); 

			--	pc_log.log_error('PC_INVOICE.post_premium','  called COBRA_ENROLLEMENT_NOTIFICATION  ' ||p_invoice_id );    

            pc_events.process_election_status_event(p_invoice_id, null);
        end if;

    end post_premium;

 -- added by vanitha for COBRA project
    function is_autopay_scheduled (
        p_entty_id    in number,
        p_entity_type in varchar2
    ) return varchar2 is
        l_flag varchar2(1) := 'N';
    begin
        for x in (
            select
                autopay
            from
                invoice_parameters
            where
                    entity_id = p_entty_id
                and entity_type = p_entity_type
        ) loop
            l_flag := x.autopay;
        end loop;

        return nvl(l_flag, 'N');
    end is_autopay_scheduled;

    procedure post_cc_for_premium (
        p_batch_number in number
    ) is

        l_invoice_line_id     number;
        l_send_enroll_confirm varchar2(1) := 'N';
        l_reinstate_confirm   varchar2(1) := 'N';
    begin
        for a in (
            select
                i.invoice_amount,
                i.invoice_id,
                i.entity_id,
                a.batch_number,
                a.transaction_id,
                a.creation_date
            from
                credit_card_invoice_payments a,
                ar_invoice                   i
            where
                    a.batch_number = p_batch_number
                and a.invoice_id = i.invoice_id
                and a.transaction_response_code in ( 1, 4 )
        ) loop
              -- insert credit card fee
            pc_invoice.insert_invoice_line(
                p_invoice_id        => a.invoice_id,
                p_invoice_line_type => 'Credit Card Fee',
                p_rate_code         => '260',
                p_description       => 'Credit Card fee',
                p_quantity          => 1,
                p_no_of_months      => 1,
                p_rate_cost         => a.invoice_amount * g_credit_card_fee,
                p_total_cost        => a.invoice_amount * g_credit_card_fee,
                p_batch_number      => a.batch_number,
                x_invoice_line_id   => l_invoice_line_id
            );

            update ar_invoice_lines
            set
                status = 'PROCESSED'
            where
                invoice_line_id = l_invoice_line_id;

            insert into income (
                change_num,
                acc_id,
                fee_date,
                fee_code,
                amount,
                pay_code,
                cc_number,
                note,
                amount_add,
                ee_fee_amount,
                list_bill,
                transaction_type
            )
                select
                    change_seq.nextval,
                    acc_id,
                    creation_date,
                    reason_code,
                    0,
                    pay_code,
                    'CC' || transaction_id -- Added by Swamy for Ticket#7723
                    ,
                    'Premium posted on '
                    || sysdate
                    || ' for '
                    || to_char(start_date, 'MM/DD/YYYY')
                    || '-'
                    || to_char(end_date, 'MM/DD/YYYY'),
                    case
                        when nvl(amount, 0) + nvl(subsidy, 0) < 0 then
                            nvl(amount, 0)
                        else
                            nvl(amount, 0) + nvl(subsidy, 0)
                    end,
                    case
                        when nvl(amount, 0) + nvl(subsidy, 0) < 0 then
                            nvl(fee_amount, 0) - ( nvl(amount, 0) + nvl(subsidy, 0) )
                        else
                            nvl(fee_amount, 0)
                    end,
                    invoice_id,
                    'I'
                from
                    (
                        select
                            ac.acc_id,
                            a.creation_date,
                            92 reason_code,
                            2  pay_code,
                            a.transaction_id,
                            a.invoice_id,
                            sum(
                                case
                                    when pr.reason_type = 'PREMIUM' then
                                        il.total_line_amount
                                    else
                                        0
                                end
                            )  amount,
                            sum(
                                case
                                    when pr.reason_type = 'FEE' then
                                        il.total_line_amount
                                    else
                                        0
                                end
                            )  fee_amount,
                            sum(
                                case
                                    when pr.reason_type like '%SUBSIDY' then
                                        il.total_line_amount
                                    else
                                        0
                                end
                            )  subsidy,
                            i.start_date,
                            i.end_date
                        from
                            ar_invoice       i,
                            ar_invoice_lines il,
                            account          ac,
                            pay_reason       pr
                        where
                                i.invoice_id = a.invoice_id
                            and i.invoice_reason = 'PREMIUM'
                            and i.entity_type = 'PERSON'
                            and i.entity_id = ac.pers_id
                            and il.status = 'PROCESSED'
                            and i.invoice_id = il.invoice_id
                            and il.rate_code = pr.reason_code
                            and not exists (
                                select
                                    *
                                from
                                    income
                                where
                                        income.acc_id = ac.acc_id
                                    and list_bill = i.invoice_id
                                    and fee_date = a.creation_date
                            )
                        group by
                            ac.acc_id,
                            a.creation_date,
                            a.transaction_id,
                            a.invoice_id,
                            i.start_date,
                            i.end_date
                    );

            update ar_invoice_lines
            set
                status = 'POSTED'
            where
                    invoice_id = a.invoice_id
                and status = 'PROCESSED';

            update ar_invoice h
            set
                status = 'POSTED',
                bank_acct_id = null,
                invoice_amount = (
                    select
                        sum(total_line_amount)
                    from
                        ar_invoice_lines l
                    where
                            l.invoice_id = h.invoice_id
                        and status not in ( 'VOID', 'CANCELLED' )
                ),
                pending_amount = 0,
                paid_amount = (
                    select
                        sum(amount + amount_add + ee_fee_amount)
                    from
                        income l
                    where
                            l.list_bill = h.invoice_id
                        and l.acc_id = h.acc_id
                ),
                invoice_posted_date = sysdate,
                last_update_date = sysdate,
                last_updated_by = 0,
                payment_method = 'CREDIT_CARD'
            where
                    invoice_id = a.invoice_id
                and status = 'PROCESSED';

            pc_events.process_election_status_event(a.invoice_id, null);
        end loop;
    end post_cc_for_premium;

-- Added by Joshi for 10742
    procedure generate_amendment_fee_invoice (
        p_acc_id number
    ) is

        l_account_type     varchar2(30);
        l_entrp_id         number;
        l_rate_plan_id     number;
        l_invoice_param_id number;
        l_amendment_fee    number;
        x_return_status    varchar2(1);
        x_error_message    varchar2(4000);
        l_batch_number     number;
    begin
        x_return_status := 'S';
        for x in (
            select
                account_type,
                entrp_id
            from
                account
            where
                acc_id = p_acc_id
        ) loop
            l_account_type := x.account_type;
            l_entrp_id := x.entrp_id;
        end loop;

-- get the rate plan details.
        if l_entrp_id is not null then
            for x in (
                select
                    rate_plan_id,
                    invoice_param_id
                from
                    invoice_parameters
                where
                        entity_id = l_entrp_id
                    and entity_type = 'EMPLOYER'
                    and invoice_type = 'FEE' --- 10918.
                    and status = 'A'
            ) loop
                l_rate_plan_id := x.rate_plan_id;
                l_invoice_param_id := x.invoice_param_id;
            end loop;

            if l_rate_plan_id > 0 then
                l_amendment_fee := pc_lookups.get_amendment_fee(l_account_type);
                pc_invoice.insert_rate_plan_detail(
                    p_rate_plan_id       => l_rate_plan_id,
                    p_calculation_type   => 'AMOUNT',
                    p_minimum_range      => null,
                    p_maximum_range      => null,
                    p_description        => null,
                    p_rate_code          =>
                                 case
                                     when l_account_type = 'FSA' then
                                         48
                                     when l_account_type = 'HRA' then
                                         47
                                     else
                                         53
                                 end, -- Added by jaggi #10962
                    p_rate_plan_cost     => l_amendment_fee,
                    p_rate_basis         => 'FLAT_FEE',
                    p_effective_date     => sysdate,
                    p_effective_end_date => null,
                    p_one_time_flag      => 'Y',
                    p_invoice_param_id   => l_invoice_param_id,
                    p_user_id            => 0,
                    p_charged_to         => null   -- added by swamy for ticket#11119
                );

                pc_invoice.generate_invoice(
                    p_start_date    => sysdate,
                    p_end_date      => sysdate,
                    p_billing_date  => sysdate,
                    p_entrp_id      => l_entrp_id,
                    p_account_type  => null,
                    x_error_status  => x_return_status,
                    x_error_message => x_error_message,
                    p_invoice_type  => 'SETUP',   --- 10908.
                    p_division_code => null,
                    x_batch_number  => l_batch_number
                );

            end if;

        end if;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
            pc_log.log_error('PC_INVOICE.generate_amendment_fee_invoice', 'Error message ' || x_error_message);
            rollback;
    end generate_amendment_fee_invoice;

-- Added by Joshi for 10847
    function get_product_type (
        p_invoice_id number
    ) return varchar2 is
        l_product_type varchar2(30) := 'FSA';
    begin
        for x in (
            select
                p.product_type
            from
                ar_invoice_lines arl,
                ar_invoice       ar,
                pay_reason       p
            where
                    ar.invoice_id = arl.invoice_id
                and arl.rate_code = p.reason_code
                and ar.invoice_id = p_invoice_id
                and p.product_type is not null
        ) loop
            l_product_type := x.product_type;
        end loop;

        return ( l_product_type );
    end get_product_type;

--Added by Joshi for GA consolidated stmt(11061)
    function get_invoice_frequency (
        p_invoice_id number
    ) return varchar2 is
        ls_invoice_frequency varchar2(30);
    begin
        for x in (
            select distinct
                ip.invoice_frequency
            from
                ar_invoice         ar,
                invoice_parameters ip
            where
                    ip.entity_id = ar.entity_id
                and ip.entity_type = 'EMPLOYER'
                and ar.rate_plan_id = ip.rate_plan_id
                and ip.status = 'A'
                and ip.invoice_type = 'FEE'
                and ar.invoice_id = p_invoice_id
        ) loop
            ls_invoice_frequency := x.invoice_frequency;
        end loop;

        return ( ls_invoice_frequency );
    end get_invoice_frequency;

-- Added by Swamy/Joshi for Ticket#11119
    procedure generate_daily_setup_renewal_invoice (
        p_entrp_id in number default null
    ) is

        l_rate_plan_id         number;
        l_inv_param_id         number;
        l_bank_acct_id         number;
        l_payment_method       varchar2(100);
        l_rate_code            number;
        l_reason_name          varchar2(250);
        l_fee                  number;
        l_batch_number         number;
        x_error_status         varchar2(1);
        x_error_message        varchar2(4000);
        l_invoice_batch_number number;
        lc_rate_plan_id        number;
    begin
        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'begin ' || l_batch_number);
        l_batch_number := daily_enroll_renewl_seq.nextval;

--Enrollments
        pc_invoice.insert_daily_enroll_renewal_account_info(l_batch_number, p_entrp_id, 'SETUP');
        pc_invoice.generate_daily_setup_invoice(l_batch_number, p_entrp_id);

-- Renewals
        pc_invoice.insert_daily_enroll_renewal_account_info(l_batch_number, p_entrp_id, 'RENEWAL');
        pc_invoice.generate_daily_renewal_invoice(l_batch_number, p_entrp_id);
    exception
        when others then
            pc_log.log_error('pc_invoice.Generate_daily_setup_renewal_invoice: ', sqlerrm);
            rollback;
    end generate_daily_setup_renewal_invoice;

-- Added by Swamy/Joshi for Ticket#11119
    procedure insert_daily_enroll_renewal_account_info (
        p_batch_number in number,
        p_entrp_id     in number default null,
        p_source       in varchar2
    ) is
--daily_enroll_renewal  daily_enroll_renewal_t;
        l_pay_acct_fees              varchar2(50);
        l_payment_method             varchar2(50);
        l_no_of_employees            number;
        l_no_of_eligible             number;
        l_quote_header               ar_quote_headers%rowtype;
        l_quote_header_id            number;
        l_billing_frequency          varchar2(50);
        l_bank_acct_num              varchar2(20);
        l_end_date                   date;
        l_renewal_creation_date      date;
        l_mth_opt_fee_paid_by        varchar2(150);
        l_mth_opt_fee_payment_method varchar2(150);
        l_mth_opt_fee_bank_acct_id   number;
    begin
        if p_source = 'SETUP' then

-- enrollment
            insert into daily_enroll_renewal_account_info (
                batch_number,
                entrp_id,
                source,
                invoice_id,
                error_status,
                error_message,
                creation_date,
                billing_frequency,
                pay_acct_fees,
                no_of_employees,
                quote_header_id,
                payment_method,
                total_quote_price,
                no_of_eligible,
                salesrep,
                account_type,
                acc_num,
                acc_id,
                broker_id,
                ga_id,
                ben_plan_created_by,
                enrolle_type,
                bank_acct_num,
                staging_batch_number
            -- ,NAME
                ,
                mth_opt_fee_paid_by       -- Added by jaggi #11263
                ,
                mth_opt_fee_payment_method,
                mth_opt_fee_bank_acct_id,
                funding_payment_method,
                product_type
            )
                (
                    select
                        p_batch_number,
                        entrp_id,
                        p_source       source,
                        null           invoice_id,
                        null           error_statis,
                        null           error_message,
                        trunc(sysdate) creation_date,
                        billing_frequency,
                        upper(pay_acct_fees),
                        no_of_employees,
                        quote_header_id,
                        payment_method,
                        total_quote_price,
                        no_of_eligible,
                        salesrep,
                        account_type,
                        acc_num,
                        acc_id,
                        broker_id,
                        ga_id,
             --enrolled_by  ben_plan_created_by,
                        submit_by      ben_plan_created_by,
                        enrolle_type,
                        bank_acc_num,
                        batch_number
            --  Name
                        ,
                        mth_opt_fee_paid_by         -- Added by jaggi #11263
                        ,
                        mth_opt_fee_payment_method,
                        mth_opt_fee_bank_acct_id,
                        funding_payment_method,
                        product_type
                    from
                        (
                            select distinct
                                a.entrp_id,
                                b.acc_id,
                                b.acc_num,
                                b.account_type,
                                null                                                         salesrep,
                                0                                                            no_of_eligible,
                                c.total_quote_price
                    -- ,c.payment_method
                                ,
                                nvl(c.payment_method, 'ACH_PUSH')                            payment_method -- Added by Joshi for 12277. 
                                ,
                                c.quote_header_id,
                                0                                                            no_of_employees,
                                nvl(
                                    decode(
                                        upper(oc.acct_payment_fees),
                                        'GENERAL AGENT',
                                        'GA',
                                        upper(oc.acct_payment_fees)
                                    ),
                                    'EMPLOYER'
                                )                                                            pay_acct_fees
                     --,NVL(oc.acct_payment_fees, 'EMPLOYER')  pay_acct_fees
                                ,
                                decode(billing_frequency, 'A', 'ONCE', 'M', 'MONTHLY',
                                       null, 'ONCE')                                         billing_frequency,
                                decode(b.enrolle_type, 'BROKER', b.enrolled_by, b.broker_id) broker_id,
                                b.ga_id
                     --,b.enrolled_by
                                ,
                                b.submit_by,
                                b.enrolle_type,
                                oc.bank_acc_num,
                                oc.batch_number,
                                upper(optional_fee_paid_by)                                  mth_opt_fee_paid_by       -- Added by jaggi #11262
                                ,
                                oc.optional_fee_payment_method                               mth_opt_fee_payment_method,
                                oc.optional_fee_bank_acct_id                                 mth_opt_fee_bank_acct_id,
                                null                                                         as funding_payment_method,
                                b.account_type                                               product_type
                            from
                                enterprise                a,
                                account                   b,
                                ar_quote_headers          c,
                                online_compliance_staging oc
                            where
                                    a.entrp_id = nvl(p_entrp_id, a.entrp_id)
                                and a.entrp_id = b.entrp_id
                                and b.entrp_id = c.entrp_id
                                and oc.entrp_id = c.entrp_id
                                and b.account_type in ( 'COBRA', 'POP', 'ERISA_WRAP' )
                                and oc.entrp_id = a.entrp_id
                                and nvl(oc.source, '*') <> 'RENEWAL'
                                and b.account_status = 1
                                and b.id_verified = 'Y'
                                and b.verified_by is not null
           -- AND TRUNC(b.verified_date) = trunc(sysdate)
          --  AND TRUNC (add_business_days(2, b.verified_date)) = trunc(sysdate)
                                and trunc(add_business_days(1, b.verified_date)) = trunc(sysdate) -- commented above and added by joshi for 12440
                                and c.quote_header_id = (
                                    select
                                        max(quote_header_id)
                                    from
                                        ar_quote_headers ci
                                    where
                                        c.entrp_id = ci.entrp_id
                                )
                                and oc.batch_number = (
                                    select
                                        max(batch_number)    -- Added by Joshi for 12283 
                                    from
                                        online_compliance_staging oci
                                    where
                                            oci.entrp_id = oc.entrp_id
                                        and nvl(oci.source, '*') <> 'RENEWAL'
                                )
                            union
                            select distinct
                                a.entrp_id,
                                b.acc_id,
                                b.acc_num,
                                b.account_type,
                                null                                                         salesrep,
                                0                                                            no_of_eligible,
                                oc.grand_total_price                                         total_quote_price
                    --    ,oc.payment_method
                                ,
                                nvl(c.payment_method, 'ACH_PUSH')                            payment_method -- Added by Joshi for 12277. 
                                ,
                                c.quote_header_id,
                                0                                                            no_of_employees
                       -- , NVL(oc.acct_payment_fees, 'EMPLOYER')  pay_acct_fees -- added by jaggi #11263
                                ,
                                nvl(
                                    decode(
                                        upper(oc.acct_payment_fees),
                                        'GENERAL AGENT',
                                        'GA',
                                        upper(oc.acct_payment_fees)
                                    ),
                                    'EMPLOYER'
                                )                                                            pay_acct_fees,
                                'ONCE'                                                       billing_frequency,
                                decode(b.enrolle_type, 'BROKER', b.enrolled_by, b.broker_id) broker_id,
                                b.ga_id
                        --,b.enrolled_by
                                ,
                                b.submit_by,
                                b.enrolle_type,
                                oc.bank_acc_num,
                                oc.batch_number,
                                null                                                         as mth_opt_fee_paid_by       -- Added by jaggi #11263
                                ,
                                null                                                         as mth_opt_fee_payment_method,
                                null                                                         as mth_opt_fee_bank_acct_id,
                                null                                                         as funding_payment_method,
                                b.account_type                                               product_type
                            from
                                enterprise               a,
                                account                  b,
                                online_form_5500_staging oc,
                                ar_quote_headers         c
                            where
                                    a.entrp_id = nvl(p_entrp_id, a.entrp_id)
                                and a.entrp_id = b.entrp_id
                                and b.entrp_id = oc.entrp_id
                                and b.account_type = 'FORM_5500'
                                and oc.entrp_id = a.entrp_id
                                and nvl(oc.source, '*') <> 'RENEWAL'
                                and nvl(oc.inactive_plan_flag, 'N') = 'N'
                                and b.entrp_id = c.entrp_id
                                and b.account_status = 1
                                and b.id_verified = 'Y'
                                and b.verified_by is not null
                --AND TRUNC(b.verified_date) = trunc(sysdate)
                --AND TRUNC (add_business_days(2, b.verified_date)) = trunc(sysdate)
                                and trunc(add_business_days(1, b.verified_date)) = trunc(sysdate) -- commented above and added by joshi for 12440
                            union
                            select distinct
                                a.entrp_id,
                                a.acc_id,
                                a.acc_num,
                                a.account_type,
                                null                                                         salesrep,
                                e.no_of_eligible,
                                null                                                         total_quote_price
                       --  ,OFH.payment_method
                                ,
                                nvl(ofh.payment_method, 'ACH_PUSH')                          payment_method -- Added by Joshi for 12277. 
                                ,
                                null                                                         quote_header_id,
                                0                                                            no_of_employees
                        -- ,UPPER( OFH. pay_acct_fees) pay_acct_fees
                                ,
                                nvl(
                                    decode(
                                        upper(ofh.pay_acct_fees),
                                        'GENERAL AGENT',
                                        'GA',
                                        upper(ofh.pay_acct_fees)
                                    ),
                                    'EMPLOYER'
                                )                                                            pay_acct_fees,
                                'ONCE'                                                       as billing_frequency,
                                decode(a.enrolle_type, 'BROKER', a.enrolled_by, a.broker_id) broker_id,
                                a.ga_id,
                                a.submit_by,
                                a.enrolle_type,
                                null                                                         bank_acc_num -- OFH.BANK_ACC_NUM -- commented by jaggi #11263
                                ,
                                ofh.batch_number,
                                upper(monthly_fees_paid_by)                                  mth_opt_fee_paid_by          -- Added by jaggi #11263
                                ,
                                monthly_fee_payment_method                                   mth_opt_fee_payment_method,
                                monthly_fee_bank_acct_id                                     mth_opt_fee_bank_acct_id,
                                funding_payment_method,
                                pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP')   product_type
                            from
                                enterprise                  e,
                                account                     a,
                                online_fsa_hra_staging      ofh,
                                ben_plan_enrollment_setup   b,
                                online_fsa_hra_plan_staging ops
                            where
                                    e.entrp_id = nvl(p_entrp_id, b.entrp_id)
                                and a.entrp_id = ofh.entrp_id
                                and ofh.batch_number = ops.batch_number
                                and ofh.entrp_id = ops.entrp_id
                                and ops.plan_type = b.plan_type
                                and b.acc_id = a.acc_id
                                and e.entrp_id = a.entrp_id
                                and a.id_verified = 'Y'
                                and a.account_type in ( 'HRA', 'FSA' )
                                and a.account_status = 1
                                and a.id_verified = 'Y'
                                and a.verified_by is not null
                        --AND TRUNC (add_business_days(2,a.verified_date)) = trunc(sysdate)
                                and trunc(add_business_days(1, a.verified_date)) = trunc(sysdate) -- commented above and added by joshi for 12440
                                and ofh.enrollment_id = (
                                    select
                                        max(enrollment_id)
                                    from
                                        online_fsa_hra_staging o
                                    where
                                            o.entrp_id = ofh.entrp_id
                                        and nvl(o.source, 'SETUP') = 'SETUP'
                                )
                        )
                );

            for k in (
                select
                    entrp_id,
                    last_day(sysdate) end_day,
                    account_type,
                    quote_header_id -- Added by Swamy for Ticket#11708
                from
                    daily_enroll_renewal_account_info
                where
                        batch_number = p_batch_number
                    and source = p_source
                    and nvl(invoice_id, 0) = 0
            ) loop
       /* FOR j IN (         SELECT MAX(plan_start_date) plan_start_date, MAX(plan_end_date) plan_end_date
                                    FROM ben_plan_enrollment_setup
                                  WHERE entrp_id = K.entrp_id
                                      AND NVL(plan_type, '*') not in ('TRN','PKG','UA1')
                                      AND status = 'A' )
        LOOP
        */
                for j in (
                    select
                        p.plan_start_date,
                        p.plan_end_date
                    from
                        (
                            select
                                max(plan_start_date) plan_start_date,
                                max(plan_end_date)   plan_end_date
                            from
                                ben_plan_enrollment_setup
                            where
                                    entrp_id = k.entrp_id
                                and nvl(plan_type, '*') not in ( 'TRN', 'PKG', 'UA1' )
                                and nvl(product_type, '*') not in ( 'FORM_5500' )  -- Added by Swamy for Ticket#11708
                                and status = 'A'
                            union
                                 -- Commented below and added line by Joshi for 12566/INC19081.
                                --   SELECT  MAX(b.plan_start_date) plan_start_date, MAX(decode( to_char(plan_end_date, 'YYYY') , '2099' , TO_DATE('12/31/' ||TO_CHAR(SYSDATE, 'YYYY'), 'MM/DD/YYYY') , plan_end_date)) plan_end_date
                            select
                                max(b.plan_start_date) plan_start_date,
                                max(decode(
                                    to_char(plan_end_date, 'YYYY'),
                                    '2099',
                                    add_months(b.plan_start_date, 12) - 1,
                                    plan_end_date
                                ))                     plan_end_date
                            from
                                ben_plan_enrollment_setup b
                            where
                                    entrp_id = k.entrp_id
                                and nvl(plan_type, '*') in ( 'TRN', 'PKG', 'UA1' )
                                and status = 'A'
                                and b.product_type = 'FSA'
                                and not exists (
                                    select
                                        *
                                    from
                                        ben_plan_enrollment_setup d
                                    where
                                            d.acc_id = b.acc_id
                                        and plan_type not in ( 'TRN', 'PKG', 'UA1' )
                                        and nvl(product_type, '*') not in ( 'FORM_5500' )  -- Added by Swamy for Ticket#11708
                                        and d.status = 'A'
                                )
                        ) p
                    where
                        p.plan_start_date is not null
                ) loop
                    l_end_date := j.plan_end_date;
          -- in case of form5500, when there are more than one plans, then the second plan is taking the sum of invoice amount due to effective end date(usually sysdate) >= p_end_date in procedure PC_INVOICE.PROCESS_POP_ERISA_5500_INV
          -- hence making then plan_end_date as end of current month day.
                    if
                        k.account_type = 'FORM_5500'
                        and trunc(j.plan_end_date) < trunc(sysdate)
                    then
                        l_end_date := k.end_day;
                    end if;

                    update daily_enroll_renewal_account_info d
                    set
                        d.plan_start_date = j.plan_start_date,
                        d.plan_end_date = l_end_date
                    where
                            d.entrp_id = k.entrp_id
                        and d.source = 'SETUP'
                        and batch_number = p_batch_number;

                end loop;

            -- Added by Swamy for Ticket#11708
                for j in (
                    select
                        max(b.plan_start_date)  plan_start_date,
                        max(b.plan_end_date)    plan_end_date,
                        max(ql.line_list_price) line_list_price
                    from
                        ben_plan_enrollment_setup b,
                        ar_quote_headers          q,
                        ar_quote_lines            ql
                    where
                            b.entrp_id = k.entrp_id
                        and nvl(b.product_type, '*') = 'FORM_5500'
                        and status = 'A'
                        and b.ben_plan_id = q.ben_plan_id
                        and q.quote_header_id = k.quote_header_id
                        and q.quote_header_id = ql.quote_header_id
                ) loop
                    l_end_date := j.plan_end_date;
              -- in case of form5500, when there are more than one plans, then the second plan is taking the sum of invoice amount due to effective end date(usually sysdate) >= p_end_date in procedure PC_INVOICE.PROCESS_POP_ERISA_5500_INV
              -- hence making then plan_end_date as end of current month day.
                    update daily_enroll_renewal_account_info d
                    set
                        d.plan_start_date = j.plan_start_date,
                        d.plan_end_date = j.plan_end_date,
                        d.total_quote_price = j.line_list_price
                    where
                            d.entrp_id = k.entrp_id
                        and d.source = 'SETUP'
                        and batch_number = p_batch_number
                        and d.account_type = 'FORM_5500'
                        and d.quote_header_id = k.quote_header_id;

                end loop;

            end loop;

            for k in (
                select
                    entrp_id
                from
                    daily_enroll_renewal_account_info
                where
                        source = p_source
                    and nvl(invoice_id, 0) <> 0
            ) loop
                update daily_enroll_renewal_account_info
                set
                    invoice_id = - 1,
                    error_status = 'E',
                    error_message = ' Duplicate record exists'
                where
                        entrp_id = k.entrp_id
                    and batch_number = p_batch_number
                    and nvl(invoice_id, 0) = 0;

            end loop;

            for k in (
                select
                    entrp_id,
                    batch_number,
                    account_type,
                    staging_batch_number
                from
                    daily_enroll_renewal_account_info
                where
                        source = 'SETUP'
                    and nvl(invoice_id, 0) = 0
                    and account_type in ( 'FSA', 'HRA' )
            ) loop
                pc_log.log_error('insert_daily_enroll_renewal_account_info', 'insert_daily_enroll_renewal_account_info  for fsa/hra k.account_type :='
                                                                             || k.account_type
                                                                             || 'k.entrp_id :='
                                                                             || k.entrp_id);

                for m in (
                    select
                        u.bank_acct_num
                    from
                        user_bank_acct_staging u
                    where
                            u.account_type = k.account_type
                        and u.entrp_id = k.entrp_id
                        and validity = 'V'
                        and acct_usage = 'FEE'  -- Added by Joshi for 10263
                        and u.batch_number = k.staging_batch_number
                ) loop
                    update daily_enroll_renewal_account_info d
                    set
                        d.bank_acct_num = m.bank_acct_num
                    where
                            d.entrp_id = k.entrp_id
                        and d.account_type = k.account_type
                        and d.source = p_source
                        and nvl(d.invoice_id, 0) = 0
                        and d.batch_number = k.batch_number;

                end loop;

            end loop;

        else
-- Renewal
            for rec in (
                select
                    a.entrp_id,
                    a.account_type,
                    a.acc_num,
                    a.acc_id,
                    b.start_date,
                    b.end_date,
                    decode(b.plan_type, 'FORM_5500', b.ben_plan_id, b.renewed_plan_id) renewed_plan_id,
                    a.broker_id,
                    a.ga_id,
                    b.created_by,
                    a.renewed_by,
                    b.ben_plan_id,
                    b.renewed_plan_id                                                  renewed_plan_id_1
            --,b.pay_acct_fees
                    ,
                    nvl(
                        decode(
                            upper(b.pay_acct_fees),
                            'GENERAL AGENT',
                            'GA',
                            upper(b.pay_acct_fees)
                        ),
                        'EMPLOYER'
                    )                                                                  pay_acct_fees,
                    b.renewal_batch_number,
                    a.account_type                                                     product_type,
                    nvl(
                        decode(
                            upper(b.optional_fee_paid_by),
                            'GENERAL AGENT',
                            'GA',
                            upper(b.optional_fee_paid_by)
                        ),
                        'EMPLOYER'
                    )                                                                  optional_fee_paid_by
                from
                    ben_plan_renewals b,
                    account           a
                where
                        a.entrp_id = nvl(p_entrp_id, a.entrp_id)
  -- AND TRUNC(b.creation_date)  = trunc(sysdate)  -- changed bcoz of the CRON
  --AND TRUNC(b.creation_date)  = trunc(sysdate) -1
                    and trunc(add_business_days(7, b.creation_date)) = trunc(sysdate)  -- Added by Joshi for 11636.
                    and a.acc_id = b.acc_id
                    and nvl(b.ben_plan_id, 0) <> 0
                    and a.account_status = 1
--and a.acc_id in (273621,279146)
                    and a.account_type in ( 'POP', 'ERISA_WRAP', 'FORM_5500', 'COBRA' )
                union
                select distinct
                    a.entrp_id,
                    a.account_type,
                    a.acc_num,
                    a.acc_id,
                    null                                                       start_date,
                    null                                                       end_date,
                    null                                                       renewed_plan_id,
                    a.broker_id,
                    a.ga_id,
                    null                                                       created_by,
                    a.renewed_by,
                    null                                                       ben_plan_id,
                    null                                                       renewed_plan_id_1,
                    null                                                       pay_acct_fees,
                    null                                                       renewal_batch_number,
                    pc_lookups.get_meaning(b.plan_type, 'FSA_HRA_PRODUCT_MAP') product_type,
                    nvl(
                        decode(
                            upper(b.optional_fee_paid_by),
                            'GENERAL AGENT',
                            'GA',
                            upper(b.optional_fee_paid_by)
                        ),
                        'EMPLOYER'
                    )                                                          optional_fee_paid_by
                from
                    ben_plan_renewals b,
                    account           a
                where
                        a.entrp_id = nvl(p_entrp_id, a.entrp_id)
            -- AND TRUNC(b.creation_date)  = trunc(sysdate) -- changed bcoz of the CRON
            -- AND TRUNC(b.creation_date)  = TRUNC(sysdate) -1
                    and trunc(add_business_days(7, b.creation_date)) = trunc(sysdate)  -- Added by Joshi for 11636.
                    and a.acc_id = b.acc_id
                    and nvl(b.ben_plan_id, 0) <> 0
                    and a.account_status = 1
                    and nvl(b.source, 'ONLINE') = 'ONLINE'
            --and a.acc_id in (273621,279146)
                    and a.account_type in ( 'FSA', 'HRA' )
            ) loop
                l_end_date := null;
                l_quote_header_id := null;
                l_payment_method := null;
                l_billing_frequency := null;
                if rec.account_type = 'FORM_5500' then  -- Added by Swamy for Ticket#11708
                    for k in (
                        select
                            ci.quote_header_id,
                            ci.payment_method,
                            decode(ci.billing_frequency, 'A', 'ONCE', 'M', 'MONTHLY',
                                   null, 'ONCE') billing_frequency,
                            b.start_date,
                            b.end_date,
                            al.line_list_price
                        from
                            ar_quote_headers  ci,
                            ben_plan_renewals b,
                            ar_quote_lines    al
                        where
                                rec.entrp_id = ci.entrp_id
                            and ci.quote_status = 'A'
                            and ci.ben_plan_id = rec.ben_plan_id
                            and ci.ben_plan_id = b.ben_plan_id
                            and ci.quote_header_id = al.quote_header_id
                    ) loop
                        l_quote_header_id := k.quote_header_id;
                        l_payment_method := k.payment_method;
                        l_billing_frequency := k.billing_frequency;
                        rec.start_date := k.start_date;
                        l_end_date := k.end_date;
                    end loop;
                elsif rec.account_type = 'ERISA_WRAP' then  -- now
                    for k in (
                        select
                            quote_header_id,
                            payment_method,
                            decode(billing_frequency, 'A', 'ONCE', 'M', 'MONTHLY',
                                   null, 'ONCE') billing_frequency
                        from
                            ar_quote_headers ci
                        where
                                rec.entrp_id = ci.entrp_id
                            and ci.quote_status = 'A'
                            and ci.quote_header_id = (
                                select
                                    max(ar.quote_header_id) quote_header_id
                                from
                                    ar_quote_headers ar
                                where
                                        rec.entrp_id = ar.entrp_id
                                    and ar.quote_status = 'A'
                            )
                    ) loop
                        l_quote_header_id := k.quote_header_id;
                        l_payment_method := k.payment_method;
                        l_billing_frequency := k.billing_frequency;
                    end loop;
                elsif rec.account_type = 'COBRA' then  -- now
      -- For COBRA,in ar_quote_headers table the ben_plan_id is stored in batch number column in pc_web_compliance.INSRT_AR_QUOTE_HEADERS
       -- For COBRA,in some cases ar_quote_headers table the ben_plan_id is stored in ben_plan-id column and not batch number column
                    for k in (
                        select
                            quote_header_id,
                            payment_method,
                            decode(billing_frequency, 'A', 'ONCE', 'M', 'MONTHLY',
                                   null, 'ONCE') billing_frequency,
                            bank_acct_id,
                            optional_fee_bank_acct_id -- added by Joshi for 11262
                            ,
                            optional_fee_payment_method
                        from
                            ar_quote_headers ci
                        where
                                rec.entrp_id = ci.entrp_id
                            and ci.quote_status = 'A'
                            and ci.ben_plan_id = rec.renewed_plan_id
                    )  -- Added for ticket#11502
                   --AND ci.batch_number = rec.renewal_batch_number)
                     loop
                        l_quote_header_id := k.quote_header_id;
                        l_payment_method := k.payment_method;
                        l_billing_frequency := k.billing_frequency;
        --l_bank_acct_num                  := k.bank_acct_id;
       -- l_mth_opt_fee_paid_by            := rec.optional_fee_paid_by ;
       -- l_mth_opt_fee_payment_method     := k.optional_fee_payment_method;
        --l_mth_opt_fee_bank_acct_id       := k.optional_fee_bank_acct_id ;
                    end loop;
                elsif rec.account_type in ( 'FSA', 'HRA' ) then  -- now
                    for p in (
                        select
                            acc_id,
                            renewal_batch_number,
                            pay_acct_fees,
                            created_by,
                            trunc(creation_date) creation_date,
                            start_date,
                            end_date,
                            renewed_plan_id
                        from
                            (
                                select
                                    acc_id,
                                    renewal_batch_number,
                                    pay_acct_fees,
                                    created_by,
                                    trunc(creation_date) creation_date,
                                    max(start_date)      start_date,
                                    max(end_date)        end_date,
                                    max(renewed_plan_id) renewed_plan_id
                                from
                                    ben_plan_renewals r
                                where
                                        r.acc_id = rec.acc_id
                    -- and TRUNC(r.creation_date)  = trunc(sysdate) -- changed bcoz of the CRON
                    --   AND TRUNC(R.creation_date)  = TRUNC(sysdate) -1
                                    and trunc(add_business_days(7, r.creation_date)) = trunc(sysdate)  -- Added by Joshi for 11636.
                                    and nvl(r.ben_plan_id, 0) <> 0
                                    and r.plan_type not in ( 'TRN', 'PKG', 'UA1' )
                                group by
                                    acc_id,
                                    renewal_batch_number,
                                    pay_acct_fees,
                                    created_by,
                                    trunc(creation_date)
                                union
                                select
                                    r.acc_id,
                                    renewal_batch_number,
                                    pay_acct_fees,
                                    r.created_by,
                                    trunc(r.creation_date) creation_date,
                                    max(r.start_date)      start_date,
                                    max(r.end_date)        end_date,
                                    max(renewed_plan_id)   renewed_plan_id
                                from
                                    ben_plan_renewals r,
                                    account           a
                                where
                                        r.acc_id = rec.acc_id
                                    and r.acc_id = a.acc_id
                        -- and TRUNC(r.creation_date)  = trunc(sysdate) -- changed bcoz of the CRON
                       -- AND TRUNC(R.creation_date)  = TRUNC(sysdate)  - 1
                                    and trunc(add_business_days(7, r.creation_date)) = trunc(sysdate)  -- Added by Joshi for 11636.
                                    and nvl(r.ben_plan_id, 0) <> 0
                                    and r.plan_type in ( 'TRN', 'PKG', 'UA1' )
                                    and a.account_type = 'FSA'
                        /*AND NOT EXISTS ( SELECT * FROM BEN_PLAN_ENROLLMENT_SETUP D
                        WHERE   d.acc_id= r.acc_id AND PLAN_TYPE  NOT IN ('TRN','PKG','UA1')
                        AND    D.STATUS = 'A') */
                                group by
                                    r.acc_id,
                                    renewal_batch_number,
                                    pay_acct_fees,
                                    r.created_by,
                                    trunc(r.creation_date)
                            ) p
                        where
                            p.start_date is not null
                            and p.renewal_batch_number is not null
                    ) loop
                        rec.start_date := p.start_date;
                        l_end_date := p.end_date;
                        rec.created_by := p.created_by;
                        rec.renewed_plan_id := p.renewed_plan_id;
                        if upper(p.pay_acct_fees) = 'GENERAL AGENT' then
                            l_pay_acct_fees := 'GA';
                        else
                            l_pay_acct_fees := nvl(
                                upper(p.pay_acct_fees),
                                'EMPLOYER'
                            );
                        end if;

                        rec.renewal_batch_number := p.renewal_batch_number;
                        l_renewal_creation_date := trunc(p.creation_date);
                        exit;
                    end loop;

                    pc_log.log_error('pc_invoice', 'l_renewal_creation_date := '
                                                   || l_renewal_creation_date
                                                   || ' rec.renewal_batch_number :='
                                                   || rec.renewal_batch_number);

                    l_billing_frequency := 'MONTHLY';
                    for n in (
                        select
                            oc.bank_acc_num,
                            oc.payment_method,
                            oc.bank_name,
                            nvl(
                                decode(
                                    upper(monthly_fees_paid_by),
                                    'GENERAL AGENT',
                                    'GA',
                                    upper(monthly_fees_paid_by)
                                ),
                                'EMPLOYER'
                            )                          mth_opt_fee_paid_by -- Added by Joshi #11263
                            ,
                            monthly_fee_payment_method mth_opt_fee_payment_method,
                            monthly_fee_bank_acct_id   mth_opt_fee_bank_acct_id
                        from
                            online_fsa_hra_staging oc
                        where
                                oc.entrp_id = rec.entrp_id
                            and nvl(oc.source, 'ENROLL') = 'RENEWAL'
                            and batch_number = rec.renewal_batch_number
                    ) loop
        --l_pay_acct_fees   := upper(n.pay_acct_fees);
                        l_bank_acct_num := n.bank_acc_num;
      -- during final submit, system is using bank name to decide if its an ach or not, payment method is populated as null , so using ACH as payment method if there is bank account number in staging
                        if nvl(l_bank_acct_num, '*') <> '*' then
                            l_payment_method := 'ACH';
                        elsif
                            nvl(l_bank_acct_num, '*') = '*'
                            and nvl(n.bank_name, '*') = '*'
                            and upper(n.payment_method) = 'ACH'
                        then
                            l_payment_method := 'ACH';
                        else
                            l_payment_method := 'ACH_PUSH';
                        end if;

                        l_mth_opt_fee_paid_by := n.mth_opt_fee_paid_by;
                        l_mth_opt_fee_payment_method := n.mth_opt_fee_payment_method;
                        l_mth_opt_fee_bank_acct_id := n.mth_opt_fee_bank_acct_id;
                    end loop;

                else
                    for k in (
                        select
                            quote_header_id,
                            payment_method,
                            decode(billing_frequency, 'A', 'ONCE', 'M', 'MONTHLY',
                                   null, 'ONCE') billing_frequency
                        from
                            ar_quote_headers ci
                        where
                                rec.entrp_id = ci.entrp_id
                            and ci.quote_status = 'A'
                            and ci.ben_plan_id = rec.renewed_plan_id_1
                    /*and ci.quote_header_id = (select max(ar.quote_header_id) quote_header_id
                    from ar_quote_headers ar
                    where rec.entrp_id = ar.entrp_id
                    AND ar.quote_status = 'A')*/
                    ) loop
                        l_quote_header_id := k.quote_header_id;
                        l_payment_method := k.payment_method;
                        l_billing_frequency := k.billing_frequency;
                    end loop;
                end if;

                if rec.account_type = 'FORM_5500' then  -- now
                    for n in (
                        select
                            last_day(sysdate) end_day,
                            nvl(
                                decode(
                                    upper(oc.acct_payment_fees),
                                    'GENERAL AGENT',
                                    'GA',
                                    upper(oc.acct_payment_fees)
                                ),
                                'EMPLOYER'
                            )                 pay_acct_fees,
                            oc.bank_acc_num
                        from
                            online_form_5500_staging oc
                        where
                                rec.entrp_id = oc.entrp_id
                            and nvl(oc.source, 'ENROLL') = 'RENEWAL'
                            and trunc(creation_date) = (
                                select
                                    trunc(max(creation_date))
                                from
                                    online_form_5500_staging oca   --now
                                where
                                        rec.entrp_id = oca.entrp_id
                                    and nvl(oca.source, 'ENROLL') = 'RENEWAL'
                            )
                    ) loop
                        l_pay_acct_fees := upper(n.pay_acct_fees);
                        l_bank_acct_num := n.bank_acc_num;

         -- Commented by Swamy for Ticket#11708
         /*       l_end_date := rec.end_date;
              -- in case of form5500, when there are more than one plans, then the second plan is taking the sum of invoice amount due to effective end date(usually sysdate) >= p_end_date in procedure PC_INVOICE.PROCESS_POP_ERISA_5500_INV
              -- hence making then plan_end_date as end of current month day.
              IF  TRUNC(rec.end_date) < TRUNC(sysdate) THEN
                 l_end_date :=  N.end_day;
              END IF;
       */

                    end loop;
                elsif rec.account_type in ( 'POP', 'ERISA_WRAP', 'COBRA' ) then  -- Cobra Added by Swamy for Ticket#11364

                    for n in (
                        select
                            nvl(
                                decode(
                                    upper(oc.acct_payment_fees),
                                    'GENERAL AGENT',
                                    'GA',
                                    upper(oc.acct_payment_fees)
                                ),
                                'EMPLOYER'
                            ) pay_acct_fees,
                            oc.bank_acc_num,
                            bank_acct_id,
                            optional_fee_payment_method,
                            optional_fee_bank_acct_id
                        from
                            online_compliance_staging oc
                        where
                                rec.entrp_id = oc.entrp_id
                            and nvl(oc.source, 'ENROLL') = 'RENEWAL'
                            and trunc(creation_date) = (
                                select
                                    trunc(max(creation_date))
                                from
                                    online_compliance_staging oca
                                where
                                        rec.entrp_id = oca.entrp_id
                                    and nvl(oca.source, 'ENROLL') = 'RENEWAL'
                            )
                    ) loop
                        if rec.account_type = 'COBRA' then    -- Added by Swamy for Ticket#11364
                            l_pay_acct_fees := upper(rec.pay_acct_fees);
                            l_bank_acct_num := n.bank_acc_num;
                            l_mth_opt_fee_payment_method := n.optional_fee_payment_method;
                            l_mth_opt_fee_bank_acct_id := n.optional_fee_bank_acct_id;
                            l_mth_opt_fee_paid_by := rec.optional_fee_paid_by;
                        else
                            l_pay_acct_fees := upper(n.pay_acct_fees);
                            l_bank_acct_num := n.bank_acc_num;
                        end if;
                    end loop;

                    l_end_date := rec.end_date;
/*ELSIF REC.ACCOUNT_TYPE = 'COBRA' THEN   -- Commented by Swamy for Ticket#11364

     L_PAY_ACCT_FEES   := UPPER(REC.PAY_ACCT_FEES);
     L_END_DATE        := REC.END_DATE;*/

                end if;

                for p in (
                    select
                        a.census_numbers
                    from
                        enterprise_census a
                    where
                            a.census_code = 'NO_OF_ELIGIBLE'
                        and a.entity_id = rec.entrp_id
                        and a.entity_type = 'ENTERPRISE'
                        and last_update_date = (
                            select
                                max(last_update_date)
                            from
                                enterprise_census e
                            where
                                    e.census_code = 'NO_OF_ELIGIBLE'
                                and e.entity_id = a.entity_id
                                and a.entity_type = e.entity_type
                        )
                ) loop
                    l_no_of_eligible := p.census_numbers;
                end loop;

                insert into daily_enroll_renewal_account_info (
                    batch_number,
                    entrp_id,
                    source,
                    creation_date,
                    billing_frequency,
                    pay_acct_fees,
                    quote_header_id,
                    payment_method,
                    account_type,
                    acc_num,
                    acc_id,
                    plan_start_date,
                    plan_end_date,
                    no_of_eligible,
                    renewed_plan_id,
                    broker_id,
                    ga_id,
                    ben_plan_created_by,
                    enrolle_type,
                    bank_acct_num,
                    ben_plan_id,
                    product_type,
                    staging_batch_number -- Added by Joshi for #11289
                    ,
                    mth_opt_fee_paid_by,
                    mth_opt_fee_payment_method,
                    mth_opt_fee_bank_acct_id
                ) values ( p_batch_number,
                           rec.entrp_id,
                           p_source,
                           sysdate,
                           l_billing_frequency,
                           upper(l_pay_acct_fees),
                           l_quote_header_id,
                           l_payment_method,
                           rec.account_type,
                           rec.acc_num,
                           rec.acc_id,
                           rec.start_date,
                           l_end_date,
                           l_no_of_eligible,
                           rec.renewed_plan_id,
                           rec.broker_id,
                           rec.ga_id,
                           rec.created_by,
                           rec.renewed_by,
                           l_bank_acct_num,
                           rec.ben_plan_id,
                           rec.product_type,
                           rec.renewal_batch_number  -- Added by Joshi for  #11289
                           ,
                           l_mth_opt_fee_paid_by,
                           l_mth_opt_fee_payment_method,
                           l_mth_opt_fee_bank_acct_id );

            end loop;

    /* commented by Joshi as the renewal invoices are not generated for accounts renewed more than once.
    FOR K IN (SELECT COUNT(renewed_plan_id) cnt,MAX(entrp_id) entrp_id, renewed_plan_id
                   FROM daily_enroll_renewal_account_info
                  WHERE SOURCE = p_source
                 HAVING COUNT(renewed_plan_id) > 1
                   GROUP BY renewed_plan_id)
    LOOP
         UPDATE daily_enroll_renewal_account_info
          SET invoice_id = -1
          ,error_status = 'E'
          ,error_message = ' Duplicate record exists'
          WHERE entrp_id = K.entrp_id
          AND batch_number = p_batch_number
          AND account_type NOT IN ('HRA','FSA');
    END LOOP;
    */

        end if;
    exception
        when others then
            pc_log.log_error('insert_daily_enroll_renewal_account_info', 'insert_daily_enroll_renewal_account_info '
                                                                         || 'SQLERRM '
                                                                         || sqlerrm);
            rollback;
    end insert_daily_enroll_renewal_account_info;

-- Added by Jaggi 11129
    procedure updateinv_pay_method (
        p_invoice_id    in number,
        p_user_id       in number,
        p_account_usage in varchar2,
        p_division_code in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is
        l_error_status  varchar2(10);
        l_error_message varchar2(1000);
    begin
        x_return_status := 'S';
        for x in (
            select
                entity_id,
                invoice_id
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
        -- Update Inovice payment terms.
            update ar_invoice
            set
                payment_method = 'ACH_PUSH',
                invoice_term = 'NET15',
                auto_pay = 'N',
                bank_acct_id = null,
                last_update_date = sysdate,
                last_updated_by = p_user_id,
                note = note
                       || ' Changing the Payment Method to ACH PUSH '
                       || to_char(sysdate, 'MM/DD/YYYY')
			--   ,client_pay_method_changed_flag = 'Y'
            where
                invoice_id = p_invoice_id;

            update invoice_parameters
            set
                payment_method = 'ACH_PUSH',
                payment_term = 'NET15',
                autopay = 'N',
                bank_acct_id = null,
                last_update_date = sysdate,
                last_updated_by = p_user_id
            where
                    entity_type = 'EMPLOYER'
                and entity_id = x.entity_id
                and invoice_type = nvl(p_account_usage, 'FEE')
                and ( p_division_code is null
                      or ( p_division_code is not null
                           and division_code = p_division_code ) )
                and status = 'A';

        end loop;

    exception
        when others then
            x_return_status := 'E';
            x_error_message := sqlerrm;
    end updateinv_pay_method;

-- Added by Joshi for Ticket#11119
    procedure insert_discount_rate_lines (
        p_batch_number     in number,
        p_entrp_id         in number,
        p_quote_header_id  in number,
        p_rate_plan_id     in number,
        p_invoice_param_id in number,
        p_source           in varchar2,
        p_fee              in number
    ) is

        l_total_fee         number;
        l_discount_amt      number;
        l_calc_type         varchar2(50);
        l_rate_code         number;
        l_description       varchar2(1500);
        l_plan_start_date   date;
        l_invoice_frequency varchar2(50);
        l_charged_to        varchar2(20);
        l_one_time_flag     varchar2(1);
    begin
        for i in (
            select
                *
            from
                daily_enroll_renewal_account_info
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and source = p_source
                and nvl(quote_header_id, '-1') = nvl(p_quote_header_id, '-1')
        ) loop
            l_plan_start_date := i.plan_start_date;
            l_invoice_frequency := i.billing_frequency;
            l_charged_to := i.pay_acct_fees;
            pc_log.log_error('pc_invoice', 'l_invoice_frequency := ' || l_invoice_frequency);
        end loop;

        for x in (
            select
                setup_fee,
                setup_fee_calc_type,
                option_service_fee,
                option_service_fee_calc_type,
                pppm_fee,
                pppm_fee_calc_type,
                acc.account_type,
                renewal_fee,
                renewal_fee_calc_type,
                ed.note
            from
                employer_discount ed,
                account           acc
            where
                    acc.entrp_id = p_entrp_id
                and acc.acc_id = ed.acc_id
                and ed.discount_type = p_source
                         -- added by jaggi #11291
                and discount_rec_no = (
                    select
                        max(discount_rec_no)
                    from
                        employer_discount edi
                    where
                            edi.acc_id = ed.acc_id
                        and edi.discount_type = ed.discount_type
                        and ( discount_exp_date is null
                              or discount_exp_date > sysdate )
                )
        ) loop
            l_description := x.note; -- Added by Joshi for 12664

            if x.account_type in ( 'POP', 'FSA', 'HRA', 'ERISA_WRAP', 'FORM_5500' ) then
                if x.account_type in ( 'FSA', 'HRA', 'ERISA_WRAP', 'FORM_5500' ) then
                    l_total_fee := p_fee;
                else
                    begin
                        select
                            total_quote_price
                        into l_total_fee
                        from
                            ar_quote_headers
                        where
                            quote_header_id = p_quote_header_id;

                    exception
                        when no_data_found then
                            l_total_fee := 0;
                    end;
                end if;

                if p_source = 'SETUP' then
                    l_rate_code := 264;
                    if x.setup_fee_calc_type = 'A' then
                   -- l_discount_amt      :=  l_total_fee - X.setup_fee;
                        l_discount_amt := x.setup_fee;
                        l_calc_type := 'AMOUNT';
                --    l_description       := '$' || l_discount_amt ; --commented by Joshi for 12664
                    else
                        l_discount_amt := round(l_total_fee * x.setup_fee / 100, 2);
                        l_calc_type := 'AMOUNT';
                 --   l_description       := X.setup_fee ||'%';  --commented by Joshi for 12664
                    end if;

                else
                    l_rate_code := 265;
                    if x.renewal_fee_calc_type = 'A' then
                    --l_discount_amt      :=  l_total_fee - X.Renewal_fee;
                        l_discount_amt := x.renewal_fee;
                        l_calc_type := 'AMOUNT';
                   -- l_description       := '$' || l_discount_amt ;  --commented by Joshi for 12664
                    else
                        l_discount_amt := round(l_total_fee * x.renewal_fee / 100, 2);
                        l_calc_type := 'AMOUNT';
                 --   l_description       := X.Renewal_fee||'%' ;  --commented by Joshi for 12664
                    end if;

                end if;

                if nvl(l_discount_amt, 0) > 0 then
                    pc_invoice.insert_rate_plan_detail(
                        p_rate_plan_id       => p_rate_plan_id,
                        p_calculation_type   => 'AMOUNT',
                        p_minimum_range      => null,
                        p_maximum_range      => null,
                        p_description        => l_description,
                        p_rate_code          => l_rate_code,
                        p_rate_plan_cost     => l_discount_amt,
                        p_rate_basis         => 'FLAT_FEE',
                        p_effective_date     => l_plan_start_date, --SYSDATE,
                        p_effective_end_date => null, --SYSDATE,
                        p_one_time_flag      => 'Y',
                        p_invoice_param_id   => p_invoice_param_id,
                        p_user_id            => 0,
                        p_charged_to         => l_charged_to   -- added by swamy for ticket#11119
                    );
                end if;

            elsif x.account_type = 'COBRA' then
                for c in (
                    select
                        arl.line_list_price total_quote_price,
                        case
                            when p_source = 'SETUP' then
                                264
                            else
                                265
                        end                 reason_code
                    from
                        ar_quote_headers arh,
                        ar_quote_lines   arl,
                        rate_plan_detail rpd,
                        rate_plans       rp
                    where
                            arh.quote_header_id = p_quote_header_id
                        and arh.entrp_id = p_entrp_id
                        and rp.rate_plan_id = arl.rate_plan_id
                        and arh.quote_header_id = arl.quote_header_id
                        and rp.rate_plan_id = rpd.rate_plan_id
                        and arl.rate_plan_detail_id = rpd.rate_plan_detail_id
                        and rpd.coverage_type = 'MAIN_COBRA_SERVICE'
                    union
                    select
                        sum(arl.line_list_price) total_quote_price,
                        266                      reason_code
                    from
                        ar_quote_headers arh,
                        ar_quote_lines   arl,
                        rate_plan_detail rpd,
                        rate_plans       rp
                    where
                            arh.quote_header_id = p_quote_header_id
                        and arh.entrp_id = p_entrp_id
                        and rp.rate_plan_id = arl.rate_plan_id
                        and arh.quote_header_id = arl.quote_header_id
                        and rp.rate_plan_id = rpd.rate_plan_id
                        and arl.rate_plan_detail_id = rpd.rate_plan_detail_id
                        and rpd.coverage_type in ( 'OPTIONAL_COBRA_SERVICE_CN', 'OPEN_ENROLLMENT_SUITE', 'OPTIONAL_COBRA_SERVICE_CP',
                        'OPTIONAL_COBRA_SERVICE_SC' )
                ) loop
                    if nvl(c.total_quote_price, 0) > 0 then
                        if c.reason_code = 264 then
                            if x.setup_fee_calc_type = 'A' then
                                l_discount_amt := x.setup_fee;
                                l_calc_type := 'AMOUNT';
                             --   l_description       := '$' || l_discount_amt ;  --commented by Joshi for 12664
                            else
                                l_discount_amt := round(c.total_quote_price * x.setup_fee / 100, 2);
                                l_calc_type := 'AMOUNT';
                              --  l_description       := X.setup_fee ||'%';  --commented by Joshi for 12664
                            end if;
                        elsif c.reason_code = 265 then
                            if x.renewal_fee_calc_type = 'A' then
                                l_discount_amt := x.renewal_fee;
                                l_calc_type := 'AMOUNT';
                             --   l_description       := '$' || l_discount_amt ;  --commented by Joshi for 12664
                            else
                                l_discount_amt := round(c.total_quote_price * x.renewal_fee / 100, 2);
                                l_calc_type := 'AMOUNT';
                              --  l_description       := X.Renewal_fee||'%' ;
                            end if;
                        elsif c.reason_code = 266 then
                            if x.option_service_fee_calc_type = 'A' then
                                l_discount_amt := x.option_service_fee;
                                l_calc_type := 'AMOUNT';
                             --   l_description       := '$' || l_discount_amt ;  --commented by Joshi for 12664
                            else
                                l_discount_amt := round(c.total_quote_price * x.option_service_fee / 100, 2);
                                l_calc_type := 'AMOUNT';
                               -- l_description       := X.OPTION_SERVICE_FEE||'%' ;  --commented by Joshi for 12664
                            end if;
                        end if;

                        if nvl(l_discount_amt, 0) > 0 then
                            l_one_time_flag := null;
                            if
                                c.reason_code in ( 264, 265 )
                                and l_invoice_frequency = 'MONTHLY'
                            then
                                l_one_time_flag := 'N';
                            else
                                l_one_time_flag := 'Y';
                            end if;

                            pc_invoice.insert_rate_plan_detail(
                                p_rate_plan_id       => p_rate_plan_id,
                                p_calculation_type   => 'AMOUNT',
                                p_minimum_range      => null,
                                p_maximum_range      => null,
                                p_description        => l_description,
                                p_rate_code          => c.reason_code,
                                p_rate_plan_cost     => l_discount_amt,
                                p_rate_basis         => 'FLAT_FEE',
                                p_effective_date     => l_plan_start_date,
                                p_effective_end_date => null, --SYSDATE,
                                    --   P_ONE_TIME_FLAG            =>   CASE WHEN l_invoice_frequency = 'MONTHLY' THEN 'N' ELSE 'Y' END ,
                                p_one_time_flag      => l_one_time_flag,
                                p_invoice_param_id   => p_invoice_param_id,
                                p_user_id            => 0,
                                p_charged_to         => l_charged_to   -- added by swamy for ticket#11119
                            );

                        end if;

                    end if;
                end loop;
            end if;

        end loop;

    end insert_discount_rate_lines;

/*PROCEDURE Insert_Discount_Rate_Lines( p_entrp_id         IN NUMBER
                                    , p_rate_plan_id     IN NUMBER
                                    , p_invoice_param_id IN NUMBER
                                    , p_source           IN VARCHAR2
                                    , p_quote_header_id  IN NUMBER
                                    , p_fee              IN NUMBER
                                    ,p_plan_start_date   IN DATE)
IS
l_total_fee NUMBER;
l_discount_amt NUMBER;
l_calc_type VARCHAR2(50);
l_rate_code NUMBER;
l_description  VARCHAR2(250);

BEGIN

FOR X IN (SELECT SETUP_FEE, SETUP_FEE_CALC_TYPE, OPTION_SERVICE_FEE, OPTION_SERVICE_FEE_CALC_TYPE, PPPM_FEE, PPPM_FEE_CALC_TYPE, ACC.ACCOUNT_TYPE, RENEWAL_FEE,
                            RENEWAL_FEE_CALC_TYPE
            FROM EMPLOYER_DISCOUNT ED, ACCOUNT ACC
           WHERE ACC.ENTRP_ID =p_entrp_id
             AND ACC.ACC_ID = ED.ACC_ID
             AND ED.DISCOUNT_TYPE = P_SOURCE)
LOOP
   IF X.ACCOUNT_TYPE IN ( 'POP', 'FSA','HRA', 'ERISA_WRAP','FORM_5500' ) THEN

      IF X.ACCOUNT_TYPE IN ('FSA','HRA', 'ERISA_WRAP') THEN
          l_total_fee := p_fee;
      ELSE
          BEGIN
            SELECT total_quote_price INTO l_total_fee
              FROM ar_quote_headers
             WHERE quote_header_id = p_quote_header_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_total_fee := 0;
          END;
     END IF;

     IF P_SOURCE = 'SETUP' THEN
            l_rate_code := 264;
            IF X.SETUP_FEE_CALC_TYPE = 'A' THEN
                l_discount_amt      :=  l_total_fee - X.setup_fee;
                l_calc_type         := 'AMOUNT';
                l_description       := '$' || l_discount_amt ;
            ELSE
                l_discount_amt      := ROUND(l_total_fee*X.setup_fee/100,2);
                l_calc_type         := 'AMOUNT';
                l_description       := X.setup_fee ||'%';
            END IF;
        ELSE
            l_rate_code := 265;
            IF X.RENEWAL_FEE_CALC_TYPE = 'A' THEN
                l_discount_amt      :=  l_total_fee - X.Renewal_fee;
                l_calc_type         := 'AMOUNT';
                l_description       := '$' || l_discount_amt ;
            ELSE
                l_discount_amt      := ROUND(l_total_fee*X.renewal_fee/100,2);
                l_calc_type         := 'AMOUNT';
                l_description       := X.Renewal_fee||'%' ;
            END IF;
      END IF;
       dbms_output.put_line( 'in the fee rate plan discount loop');

         PC_INVOICE.INSERT_RATE_PLAN_DETAIL(
                    P_RATE_PLAN_ID
                    => p_rate_plan_id,
                    P_CALCULATION_TYPE  => 'AMOUNT',
                    P_MINIMUM_RANGE     => NULL,
                    P_MAXIMUM_RANGE     => NULL,
                    P_DESCRIPTION       => l_description,
                    P_RATE_CODE         => l_rate_code,
                    P_RATE_PLAN_COST    => l_discount_amt ,
                    P_RATE_BASIS        => 'FLAT_FEE',
                    P_EFFECTIVE_DATE    => p_plan_start_date,
                    P_EFFECTIVE_END_DATE => NULL,
                    P_ONE_TIME_FLAG     => 'Y' ,
                    P_INVOICE_PARAM_ID  => p_invoice_param_id,
                    P_USER_ID           => 0,
                    P_charged_to               => null   -- added by swamy for ticket#11119
                    );

    ELSIF X.ACCOUNT_TYPE = 'COBRA' THEN
        FOR C IN (   SELECT ARL.LINE_LIST_PRICE TOTAL_QUOTE_PRICE, CASE WHEN P_SOURCE = 'SETUP' THEN 264 ELSE 265 END reason_code
                       FROM AR_QUOTE_HEADERS ARH, AR_QUOTE_LINES ARL, RATE_PLAN_DETAIL RPD, RATE_PLANS RP
                      WHERE ARH.QUOTE_HEADER_ID = P_Quote_Header_Id
                        AND ARH.ENTRP_ID = P_Entrp_Id
                        AND RP.RATE_PLAN_ID = ARL.RATE_PLAN_ID
                        AND ARH.QUOTE_HEADER_ID = ARL.QUOTE_HEADER_ID
                        AND RP.RATE_PLAN_ID = RPD.RATE_PLAN_ID
                        AND ARL.RATE_PLAN_DETAIL_ID = RPD.RATE_PLAN_DETAIL_ID
                        AND RPD.COVERAGE_TYPE = 'MAIN_COBRA_SERVICE'
                      UNION
                     SELECT  SUM(ARL.LINE_LIST_PRICE) TOTAL_QUOTE_PRICE ,266 reason_code
                       FROM AR_QUOTE_HEADERS ARH, AR_QUOTE_LINES ARL, RATE_PLAN_DETAIL RPD, RATE_PLANS RP
                      WHERE ARH.QUOTE_HEADER_ID = P_Quote_Header_Id
                        AND ARH.ENTRP_ID = P_Entrp_Id
                        AND RP.RATE_PLAN_ID = ARL.RATE_PLAN_ID
                        AND ARH.QUOTE_HEADER_ID = ARL.QUOTE_HEADER_ID
                        AND RP.RATE_PLAN_ID = RPD.RATE_PLAN_ID
                        AND ARL.RATE_PLAN_DETAIL_ID = RPD.RATE_PLAN_DETAIL_ID
                        AND RPD.COVERAGE_TYPE in( 'OPTIONAL_COBRA_SERVICE_CN', 'OPEN_ENROLLMENT_SUITE', 'OPTIONAL_COBRA_SERVICE_CP'))
        LOOP
                dbms_output.put_line( 'in the cobra discount loop');
                 IF c.reason_code  = 264 THEN
                    IF X.SETUP_FEE_CALC_TYPE = 'A' THEN
                        l_discount_amt      :=  C.total_quote_price - X.setup_fee ;
                        l_calc_type         := 'AMOUNT';
                        l_description       := '$' || l_discount_amt ;
                    ELSE
                        l_discount_amt      := ROUND(c.total_quote_price*X.setup_fee/100,2);
                        l_calc_type         := 'AMOUNT';
                        l_description       := X.setup_fee ||'%';
                    END IF;
                ELSIF c.reason_code = 265 THEN
                    IF X.RENEWAL_FEE_CALC_TYPE = 'A' THEN
                        l_discount_amt      :=  C.total_quote_price - X.Renewal_fee;
                        l_calc_type         := 'AMOUNT';
                        l_description       := '$' || l_discount_amt ;
                    ELSE
                        l_discount_amt      := ROUND(c.total_quote_price*X.renewal_fee/100,2);
                        l_calc_type         := 'AMOUNT';
                        l_description       := X.Renewal_fee||'%' ;
                    END IF;
                ELSIF c.reason_code = 266 THEN
                    IF X.OPTION_SERVICE_FEE_CALC_TYPE = 'A' THEN
                        l_discount_amt      :=  c.total_quote_price - X.OPTION_SERVICE_FEE;
                        l_calc_type         := 'AMOUNT';
                        l_description       := '$' || l_discount_amt ;
                    ELSE
                        l_discount_amt      := ROUND(c.total_quote_price*X.OPTION_SERVICE_FEE/100,2);
                        l_calc_type         := 'AMOUNT';
                        l_description       := X.OPTION_SERVICE_FEE||'%' ;
                    END IF;
                END IF;

         PC_INVOICE.INSERT_RATE_PLAN_DETAIL(
                    P_RATE_PLAN_ID             => p_rate_plan_id,
                    P_CALCULATION_TYPE         => 'AMOUNT',
                    P_MINIMUM_RANGE            => NULL,
                    P_MAXIMUM_RANGE            => NULL,
                    P_DESCRIPTION              => l_description,
                    P_RATE_CODE                => c.reason_code,
                    P_RATE_PLAN_COST           => l_discount_amt ,
                    P_RATE_BASIS               => 'FLAT_FEE',
                    P_EFFECTIVE_DATE           => SYSDATE,
                    P_EFFECTIVE_END_DATE       => SYSDATE,
                    P_ONE_TIME_FLAG            => 'Y' ,
                    P_INVOICE_PARAM_ID         => p_invoice_param_id,
                    P_USER_ID                  => 0 ,
                    P_charged_to               => null   -- added by swamy for ticket#11119
                    );
        END LOOP;
    END IF;
END LOOP;
END Insert_Discount_Rate_Lines;
*/

-- Added by Jaggi for Ticket#11119
    procedure insert_inv_parameters (
        p_entrp_id         in number,
        p_payment_method   in varchar2,
        p_bank_acct_id     in number,
        p_payment_term     in varchar2,
        p_inv_frequency    in varchar2,
        p_rate_plan_id     in number,
        p_invoice_type     in varchar2,
        p_product_type     in varchar2,
        p_user_id          in number,
        p_billing_name     in varchar2,
        p_billing_attn     in varchar2,
        p_billing_address  in varchar2,
        p_billing_city     in varchar2,
        p_billing_zip      in varchar2,
        p_billing_state    in varchar2,
        x_invoice_param_id out number
    ) is
    begin
        pc_log.log_error('insert_daily_enroll_renewal_account_info', 'inside INSERT_INVOICE_LINE o ');
        insert into invoice_parameters (
            invoice_param_id,
            entity_id,
            entity_type,
            payment_method,
            bank_acct_id,
            autopay,
            payment_term,
            invoice_frequency,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            send_invoice_reminder,
            rate_plan_id,
            invoice_type,
            product_type,
            status,
            billing_name,
            billing_attn,
            billing_address,
            billing_city,
            billing_zip,
            billing_state
        ) values ( invoice_parameters_seq.nextval,
                   p_entrp_id,
                   'EMPLOYER',
                   p_payment_method,
                   p_bank_acct_id,
                   decode(p_payment_method, 'DIRECT_DEPOSIT', 'Y', 'N'),
                   p_payment_term,
                   p_inv_frequency,
                   sysdate,
                   p_user_id,
                   sysdate,
                   p_user_id,
                   'Y',
                   p_rate_plan_id,
                   p_invoice_type,
                   p_product_type,
                   'A',
                   p_billing_name,
                   p_billing_attn,
                   p_billing_address,
                   p_billing_city,
                   p_billing_zip,
                   p_billing_state ) returning invoice_param_id into x_invoice_param_id;

    end insert_inv_parameters;

-- Added by Jaggi for Ticket#11119
    procedure setup_inv_parameter_for_employer (
        p_entrp_id       in number,
        p_batch_number   in number,
        p_payment_method in varchar2,
        p_bank_acct_id   in number,
        p_inv_frequency  in varchar2,
        p_rate_plan_id   in number
    ) is

        l_invoice_param_id       number;
        l_discount_amt           number;
        l_monthly_fee_maint      number;
        l_invoice_group          varchar2(150);
        l_payment_method         varchar2(100);
        l_funding_payment_method varchar2(100);
        l_payment_term           varchar2(100);
        l_bank_acct_id           number;
    begin
        l_discount_amt := 0;
        l_monthly_fee_maint := pc_lookups.get_fsa_hra_monthly_fee('MIN_FSA_INV_AMOUNT');
        l_payment_method := p_payment_method;
        l_bank_acct_id := p_bank_acct_id;
        for x in (
            select
                *
            from
                daily_enroll_renewal_account_info
            where
                    entrp_id = p_entrp_id
                and batch_number = p_batch_number
        ) loop
            l_funding_payment_method := nvl(x.funding_payment_method, 'ACH_PUSH');
        end loop;

        for i in (
            select
                decode(bp.claim_reimbursed_by, 'EMPLOYER', 'CLAIM_INVOICE', 'FUNDING_INVOICE') funding_option
            from
                ben_plan_enrollment_setup bp,
                account                   acc
            where
                    bp.acc_id = acc.acc_id
                and bp.claim_reimbursed_by is not null
                and acc.entrp_id = p_entrp_id
        ) loop
            l_invoice_group := i.funding_option;
        end loop;
/*
IF l_invoice_group = 'CLAIM_INVOICE'  AND P_PAYMENT_METHOD = 'DIRECT_DEPOSIT'  THEN
    For B IN ( select bank_Acct_id
                    from user_bank_acct b, account a
                    where a.acc_id = b.acc_id
                       and a.entrp_id = p_entrp_id
                       and b.status = 'A'
                       and b.bank_acct_usage = 'CLAIM')
    LOOP
        IF b.bank_acct_id IS NOT NULL them
            l_bank_acct_id := b.bank_acct_id;
        ELSE
            l_bank_acct_id :=p_bank_acct_id
        END IF;
    END LOOP;
ELSIF l_invoice_group = 'FUNDING_INVOICE'  AND P_PAYMENT_METHOD = 'DIRECT_DEPOSIT'  THEN
    For B IN (   select bank_Acct_id
                       from user_bank_acct b, account a
                    where a.acc_id = b.acc_id
                       and a.entrp_id = p_entrp_id
                       and b.bank_acct_usage = 'FUNDING'
                       and b.status = 'A')
    LOOP
        IF b.bank_acct_id IS NOT NULL them
            l_bank_acct_id := b.bank_acct_id;
        ELSE
            l_bank_acct_id :=p_bank_acct_id
        END IF;
    END LOOP;
 END IF;
*/

        for x in (
            select
                a.acc_id,
                a.account_type,
                name    as billing_name,
                address as billing_address,
                city    as billing_city,
                zip     as billing_zip,
                state   as billing_state
            from
                account    a,
                enterprise e
            where
                    a.entrp_id = e.entrp_id
                and a.entrp_id = p_entrp_id
        ) loop
            if x.account_type in ( 'FSA', 'HRA' ) then
                for i in (
                    select
                        lookup_code invoice_type
                    from
                        lookups
                    where
                            lookup_name = 'INVOICE_TYPE_REASON'
                        and lookup_code not in ( 'PREMIUM', 'DISBURSEMENT' )
                ) -- DISBURSEMENT Added by Swamy for Ticket#12443 
                 loop
                    pc_log.log_error('SETUP_INV_PARAMETER_FOR_EMPLOYER  l_bank_acct_id **0 ', l_bank_acct_id
                                                                                              || ' l_invoice_group :='
                                                                                              || l_invoice_group
                                                                                              || 'I.INVOICE_TYPE :='
                                                                                              || i.invoice_type);

                    l_bank_acct_id := null;  -- Added by Swamy for Ticket#12443
                    if l_invoice_group = 'CLAIM_INVOICE' then
                        if l_funding_payment_method = 'ACH' then -- added by #jaggi 11263
                            if i.invoice_type = 'CLAIM' then
                                for b in (
                                    select
                                        bank_acct_id
                                    from
                                        user_bank_acct b,
                                        account        a
                                    where
                                            a.acc_id = b.acc_id
                                        and a.entrp_id = p_entrp_id
                                        and b.status = 'A'
                                        and b.bank_account_usage in ( 'CLAIMS' )
                                ) loop
                                    if b.bank_acct_id is not null then
                                        l_bank_acct_id := b.bank_acct_id;
                                    end if;
                                end loop;

                                if l_bank_acct_id is not null then
                                    l_payment_method := 'DIRECT_DEPOSIT';
                                    l_payment_term := 'IMMEDIATE';
                                else
                                    l_payment_method := 'ACH_PUSH';
                                    l_payment_term := 'NET15';
                                    l_bank_acct_id := null;
                                    update daily_enroll_renewal_account_info
                                    set
                                        error_message = ' claim bank account details not found'
                                    where
                                            entrp_id = p_entrp_id
                                        and batch_number = p_batch_number;

                                end if;

                            elsif i.invoice_type = 'FUNDING' then
                                l_payment_method := 'ACH_PUSH';
                                l_payment_term := 'NET15';
                                l_bank_acct_id := null;
                            end if;

                        else
                            l_payment_method := 'ACH_PUSH';
                            l_payment_term := 'NET15';
                            l_bank_acct_id := null;
                        end if;
                    elsif l_invoice_group = 'FUNDING_INVOICE' then
                        pc_log.log_error('SETUP_INV_PARAMETER_FOR_EMPLOYER  l_funding_payment_method **0.1 ', l_funding_payment_method
                                                                                                              || ' l_invoice_group :='
                                                                                                              || l_invoice_group
                                                                                                              || 'I.INVOICE_TYPE :='
                                                                                                              || i.invoice_type);

                        if l_funding_payment_method = 'ACH' then -- added by #jaggi 11263
                            if i.invoice_type = 'FUNDING' then
                                for b in (
                                    select
                                        bank_acct_id
                                    from
                                        user_bank_acct b,
                                        account        a
                                    where
                                            a.acc_id = b.acc_id
                                        and a.entrp_id = p_entrp_id
                                        and b.status = 'A'
                                        and b.bank_account_usage in ( 'FUNDING' )
                                ) --'FUNDING'
                                 loop
                                    if b.bank_acct_id is not null then
                                        l_bank_acct_id := b.bank_acct_id;
                                    end if;
                                end loop;

                                if l_bank_acct_id is not null then
                                    l_payment_method := 'DIRECT_DEPOSIT';
                                    l_payment_term := 'IMMEDIATE';
                                else
                                    l_payment_method := 'ACH_PUSH';
                                    l_payment_term := 'NET15';
                                    l_bank_acct_id := null;
                                    update daily_enroll_renewal_account_info
                                    set
                                        error_message = ' Funding bank account details not found'
                                    where
                                            entrp_id = p_entrp_id
                                        and batch_number = p_batch_number;

                                end if;

                            elsif i.invoice_type = 'CLAIM' then
                                l_payment_method := 'ACH_PUSH';
                                l_payment_term := 'NET15';
                                l_bank_acct_id := null;
                            end if;

                        else
                            l_payment_method := 'ACH_PUSH';
                            l_payment_term := 'NET15';
                            l_bank_acct_id := null;
                        end if;

                    end if;

                    if i.invoice_type = 'FEE' then --AND P_PAYMENT_METHOD = 'DIRECT_DEPOSIT' THEN
                          /*  For B IN ( select bank_Acct_id
                                            from user_bank_acct b, account a
                                            where a.acc_id = b.acc_id
                                               and a.entrp_id = p_entrp_id
                                               and b.status = 'A'
                                               and b.bank_account_usage IN ('INVOICE','OFFICE')) --'INVOICE'
                            LOOP
                                IF b.bank_acct_id IS NOT NULL then
                                    l_bank_acct_id := NVL( b.bank_acct_id, P_BANK_ACCT_ID);
                                    l_payment_method := 'DIRECT_DEPOSIT';
                                    l_payment_term := 'IMMEDIATE' ;
                                END IF;
                            END LOOP;*/
                        l_bank_acct_id := p_bank_acct_id;
                        if p_payment_method in ( 'ACH', 'DIRECT_DEPOSIT' ) then
                            l_payment_method := 'DIRECT_DEPOSIT';
                            l_payment_term := 'IMMEDIATE';
                        else
                            l_payment_method := p_payment_method;
                            l_payment_term := 'NET15';
                        end if;

                    end if;

                    pc_log.log_error('SETUP_INV_PARAMETER_FOR_EMPLOYER  l_invoice_group', l_invoice_group);
                    pc_log.log_error('SETUP_INV_PARAMETER_FOR_EMPLOYER  i.INVOICE_TYPE', i.invoice_type);
                    pc_log.log_error('SETUP_INV_PARAMETER_FOR_EMPLOYER  l_payment_method', l_payment_method);
                    pc_log.log_error('SETUP_INV_PARAMETER_FOR_EMPLOYER  l_bank_acct_id **1 ', l_bank_acct_id);
                    insert_inv_parameters(
                        p_entrp_id         => p_entrp_id,
                        p_payment_method   => l_payment_method,  -- P_PAYMENT_METHOD,
                        p_bank_acct_id     => l_bank_acct_id,  --P_BANK_ACCT_ID,
                        p_payment_term     => l_payment_term,
                        p_inv_frequency    =>
                                         case
                                             when i.invoice_type in('CLAIM', 'FUNDING') then
                                                 'TWICE_A_WEEK'
                                             else
                                                 p_inv_frequency
                                         end,
                        p_invoice_type     => i.invoice_type,
                        p_rate_plan_id     => p_rate_plan_id,
                        p_product_type     => x.account_type,
                        p_user_id          => 0,
                        p_billing_name     => x.billing_name,
                        p_billing_attn     => null,
                        p_billing_address  => x.billing_address,
                        p_billing_city     => x.billing_city,
                        p_billing_zip      => x.billing_zip,
                        p_billing_state    => x.billing_state,
                        x_invoice_param_id => l_invoice_param_id
                    );

                    if i.invoice_type = 'FEE' then
                        for y in (
                            select
                                ed.monthly_fee_maint,
                                ed.monthly_fee_maint_calc_type
                            from
                                employer_discount ed,
                                account           acc
                            where
                                    acc.entrp_id = p_entrp_id
                                and acc.acc_id = ed.acc_id
                                and ed.discount_type = 'SETUP'
                                and discount_rec_no = (
                                    select
                                        max(discount_rec_no)
                                    from
                                        employer_discount edi
                                    where
                                            edi.acc_id = ed.acc_id
                                        and edi.discount_type = ed.discount_type
                                        and ( discount_exp_date is null
                                              or discount_exp_date > sysdate )
                                )
                        ) loop
                            if y.monthly_fee_maint_calc_type = 'A' then
                                l_discount_amt := nvl(y.monthly_fee_maint, 0);
                            else
                                l_discount_amt := round(l_monthly_fee_maint * nvl(y.monthly_fee_maint, 0) / 100,
                                                        2);
                            end if;
                        end loop;

                        if l_invoice_param_id is not null then
                            if x.account_type = 'FSA' then
                                update invoice_parameters
                                set
                                    min_inv_amount = ( l_monthly_fee_maint - l_discount_amt )
                                where
                                        entity_id = p_entrp_id
                                    and invoice_type = 'FEE'
                                    and invoice_param_id = l_invoice_param_id;

                            else
                                update invoice_parameters
                                set
                                    min_inv_hra_amount = ( l_monthly_fee_maint - l_discount_amt )
                                where
                                        entity_id = p_entrp_id
                                    and invoice_type = 'FEE'
                                    and invoice_param_id = l_invoice_param_id;

                            end if;

                        end if;

                    end if;

                end loop;

            else
                pc_log.log_error('insert_daily_enroll_renewal_account_info', 'calling INSERT_INV_PARAMETERS o ');
                insert_inv_parameters(
                    p_entrp_id         => p_entrp_id,
                    p_payment_method   => p_payment_method,
                    p_bank_acct_id     => p_bank_acct_id,
                    p_payment_term     =>
                                    case
                                        when p_payment_method in('CHECK', 'ACH_PUSH') then
                                            'NET15'
                                        else
                                            'IMMEDIATE'
                                    end,
                    p_inv_frequency    => p_inv_frequency,
                    p_invoice_type     => 'FEE',
                    p_rate_plan_id     => p_rate_plan_id,
                    p_product_type     => x.account_type,
                    p_user_id          => 0,
                    p_billing_name     => x.billing_name,
                    p_billing_attn     => null,
                    p_billing_address  => x.billing_address,
                    p_billing_city     => x.billing_city,
                    p_billing_zip      => x.billing_zip,
                    p_billing_state    => x.billing_state,
                    x_invoice_param_id => l_invoice_param_id
                );

            end if;
        end loop;

    end setup_inv_parameter_for_employer;

-- Added by Swamy for Ticket#11119
    procedure generate_daily_renewal_invoice (
        p_batch_number in number,
        p_entrp_id     in number default null
    ) is

        l_rate_plan_id              number;
        l_inv_param_id              number := null;
        l_bank_acct_id              number := null;
        l_payment_method            varchar2(100);
        l_rate_code                 number;
        l_reason_name               varchar2(250);
        l_fee                       number;
        x_error_status              varchar2(1);
        x_error_message             varchar2(4000);
        l_invoice_batch_number      number;
        lc_rate_plan_id             number;
        erreur exception;
        l_bank_entity_type          varchar2(50);
        l_bank_entity_id            number;
        l_enrolle_type              varchar2(50);
        l_broker_id                 number;
        l_payment_term              varchar2(10);
        l_auto_pay                  varchar2(10);
        l_user_type                 varchar2(10);
        l_description               varchar2(500);
        l_entity_type               varchar2(20);
        l_plan_type                 varchar2(50);
        l_plan_number               varchar2(50);
        l_invoice_frequency         varchar2(20);
        l_end_date                  date;
        l_start_date                date;
        l_fee_ndt                   number;
        l_ndt_comprehensive         varchar2(1);
        l_discount_amt              number;
        l_monthly_fee_maint         number;
        l_exist_payment_method      varchar2(100);
        l_exist_bank_acct_id        number;
        l_opt_fee_bank_acct_id      number;
        l_opt_fee_payment_method    varchar2(50);
        l_opt_fee_autopay           varchar2(1);
        l_opt_fee_payment_term      varchar2(50);
        l_opt_fee_invoice_generated varchar2(1) := 'N';
        l_exist_payment_term        varchar2(50);
        l_exist_auto_pay            varchar2(1);
        l_exist_invoice_frequency   varchar2(100);
        l_ga_id                     number;
        l_entrp_name                varchar2(500);
        l_cobra_monthly_admin_fee   number;    --- Added by Joshi for 11998
        l_active_bank_exists        varchar2(1);   -- Added by Swamy for Ticket#12534
    begin
        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'begin ' || p_batch_number);
    --pc_invoice.insert_daily_enroll_renewal_account_info( P_BATCH_NUMBER,'RENEWAL');

--Added by Joshi for 11998
        l_cobra_monthly_admin_fee := pc_invoice.get_cobra_monthly_admin_fee;
        for x in (
            select
                *
            from
                daily_enroll_renewal_account_info a
            where
                    a.batch_number = p_batch_number
                and a.source = 'RENEWAL'
                and nvl(a.invoice_id, 0) = 0
                and nvl(a.error_status, 'N') = 'N'
        ) loop
            begin
                l_inv_param_id := null;
                l_bank_acct_id := null;
                l_payment_method := null;
                l_rate_plan_id := null;
                x_error_message := null;
                x_error_status := null;
                l_fee := null;  --now
                l_bank_entity_id := null;  -- Added by Joshi for 11317
                l_bank_entity_type := null;  -- Added by Joshi for 11317
                l_invoice_frequency := x.billing_frequency;
                l_monthly_fee_maint := pc_lookups.get_fsa_hra_monthly_fee('MIN_FSA_INV_AMOUNT');
                l_exist_payment_method := null;
                l_exist_bank_acct_id := null;
                l_exist_payment_term := null;
                l_exist_auto_pay := null;
                l_exist_invoice_frequency := null;
                l_entrp_name := null;
                l_entrp_name := pc_entrp.get_entrp_name(x.entrp_id);
                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'X.entrp_id '
                                                                                    || x.entrp_id
                                                                                    || 'X.ACCOUNT_TYPE :='
                                                                                    || x.account_type);

                for h in (
                    select
                        invoice_param_id,
                        payment_method,
                        payment_term,
                        autopay,
                        bank_acct_id,
                        invoice_frequency
                    from
                        invoice_parameters p
                    where
                            p.entity_id = x.entrp_id
                        and p.entity_type = 'EMPLOYER'
                        and p.status = 'A'
                        and p.invoice_type = 'FEE'
                ) loop
                    l_inv_param_id := h.invoice_param_id;
                    l_exist_payment_method := h.payment_method;
                    l_exist_payment_term := h.payment_term;
                    l_exist_auto_pay := h.autopay;
                    l_exist_bank_acct_id := h.bank_acct_id;
                    l_exist_invoice_frequency := h.invoice_frequency;
                end loop;

       -- 12246 : commented below and added below line by Joshi. For Form5500 also there will not be invoice setup 
       -- so we need to create at the time of renewal. 
       -- IF NVL(l_inv_param_id,0) = 0  and X.ACCOUNT_TYPE = 'POP' THEN
                if nvl(l_inv_param_id, 0) = 0 then --  and X.ACCOUNT_TYPE in (  'POP' , 'FORM_5500', 'COBRA', 'ERISA_WRAP') THEN commented for 12277 by Joshi as this is applicable for all products.

            -- Start of Ticket#11989 12012024 swamy
                    for m in (
                        select
                            rate_plan_id
                        from
                            rate_plans
                        where
                                entity_id = x.entrp_id
                            and status = 'A'
                            and rate_plan_type = 'INVOICE'
                    ) loop
                        l_rate_plan_id := m.rate_plan_id;
                    end loop;

                    if nvl(l_rate_plan_id, 0) = 0 then
                        l_rate_plan_id := rate_plans_seq.nextval;
                        pc_log.log_error('PC_INVOICE.Generate_daily_renewal_invoice', ' INSERT INTO RATE_PLANS' || x.entrp_id);
                        insert into rate_plans (
                            rate_plan_id,
                            rate_plan_name,
                            entity_type,
                            entity_id,
                            status,
                            note,
                            effective_date,
                            creation_date,
                            created_by,
                            last_update_date,
                            last_updated_by,
                            rate_plan_type
                        ) values ( l_rate_plan_id,
                                   l_entrp_name,
                                   'EMPLOYER',
                                   x.entrp_id,
                                   'A',
                                   'Renewal Invoice',
                                   x.plan_start_date,
                                   sysdate,
                                   0,
                                   sysdate,
                                   0,
                                   'INVOICE' ) returning rate_plan_id into l_rate_plan_id;

                    end if;

                    if nvl(l_rate_plan_id, 0) = 0 then
                        update daily_enroll_renewal_account_info a
                        set
                            error_status = 'E',
                            error_message = ' Failed to Insert into Rate plan table'
                        where
                                a.batch_number = p_batch_number
                            and a.source = 'RENEWAL'
                            and entrp_id = x.entrp_id;

                    end if;

                    if nvl(l_rate_plan_id, 0) <> 0 then
                        for h in (
                            select
                                invoice_param_id
                            from
                                invoice_parameters p
                            where
                                    p.entity_id = x.entrp_id
                                and p.entity_type = 'EMPLOYER'
                                and p.invoice_type = 'FEE'
                                and p.status = 'A'
                        ) loop
                            l_inv_param_id := h.invoice_param_id;
                        end loop;

                        pc_log.log_error('PC_INVOICE.Generate_daily_renewal_invoice', 'l_rate_plan_id  **2 '
                                                                                      || l_rate_plan_id
                                                                                      || 'l_inv_param_id :='
                                                                                      || l_inv_param_id);
                        if nvl(l_inv_param_id, 0) = 0 then
                            pc_log.log_error('PC_INVOICE.Generate_daily_renewal_invoice', 'l_payment_method: '
                                                                                          || l_payment_method
                                                                                          || ' l_bank_acct_id := '
                                                                                          || l_bank_acct_id
                                                                                          || ' l_rate_plan_id := '
                                                                                          || l_rate_plan_id
                                                                                          || ' X.billing_frequency := '
                                                                                          || x.billing_frequency);

                            pc_invoice.setup_inv_parameter_for_employer(
                                p_entrp_id       => x.entrp_id,
                                p_batch_number   => p_batch_number,
                                p_payment_method => l_payment_method,
                                p_bank_acct_id   => l_bank_acct_id,
                                p_inv_frequency  => x.billing_frequency,
                                p_rate_plan_id   => l_rate_plan_id
                            );

                        end if;

                    end if;

                    for h in (
                        select
                            invoice_param_id,
                            payment_method,
                            payment_term,
                            autopay,
                            bank_acct_id,
                            invoice_frequency
                        from
                            invoice_parameters p
                        where
                                p.entity_id = x.entrp_id
                            and p.entity_type = 'EMPLOYER'
                            and p.status = 'A'
                            and p.invoice_type = 'FEE'
                    ) loop
                        l_inv_param_id := h.invoice_param_id;
                        l_exist_payment_method := h.payment_method;
                        l_exist_payment_term := h.payment_term;
                        l_exist_auto_pay := h.autopay;
                        l_exist_bank_acct_id := h.bank_acct_id;
                        l_exist_invoice_frequency := h.invoice_frequency;
                    end loop;

                end if;
    -- end of Ticket#11989 12012024 swamy

                if nvl(l_inv_param_id, 0) <> 0 then
                    for y in (
                        select
                            acc.account_type,
                            ed.monthly_fee_maint,
                            ed.monthly_fee_maint_calc_type
                        from
                            employer_discount ed,
                            account           acc
                        where
                                acc.entrp_id = x.entrp_id
                            and acc.acc_id = ed.acc_id
                            and ed.discount_type = 'RENEWAL'
                            and discount_rec_no = (
                                select
                                    max(discount_rec_no)
                                from
                                    employer_discount edi
                                where
                                        edi.acc_id = ed.acc_id
                                    and edi.discount_type = ed.discount_type
                                    and ( discount_exp_date is null
                                          or discount_exp_date > sysdate )
                            )
                    ) loop
                        if y.monthly_fee_maint_calc_type = 'A' then
                            l_discount_amt := nvl(y.monthly_fee_maint, 0);
                        else
                            l_discount_amt := round(l_monthly_fee_maint * nvl(y.monthly_fee_maint, 0) / 100,
                                                    2);
                        end if;

                        if l_discount_amt > 0 then
                            if y.account_type = 'FSA' then
                                update invoice_parameters
                                set
                                    min_inv_amount = ( l_monthly_fee_maint - l_discount_amt )
                                where
                                        entity_id = x.entrp_id
                                    and invoice_type = 'FEE'
                                    and invoice_param_id = l_inv_param_id;

                            elsif y.account_type = 'HRA' then
                                update invoice_parameters
                                set
                                    min_inv_hra_amount = ( l_monthly_fee_maint - l_discount_amt )
                                where
                                        entity_id = x.entrp_id
                                    and invoice_type = 'FEE'
                                    and invoice_param_id = l_inv_param_id;

                            end if;

                        end if;

                    end loop;
                end if;

                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice : X.payment_method', x.payment_method);
                if upper(x.payment_method) = 'ACH' then
                    l_payment_method := 'DIRECT_DEPOSIT';
                    l_payment_term := 'IMMEDIATE';
                    l_auto_pay := 'Y';
                    pc_broker.get_broker_id(x.ben_plan_created_by, l_entity_type, l_broker_id);

            -- Added by swamy for Ticket #11585(Dev ticket 11368)
                    if nvl(l_entity_type, '*') = '*' then
                        pc_general_agent.get_ga_id(x.ben_plan_created_by, l_entity_type, l_ga_id);
                    end if;

                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice : l_entity_type', l_entity_type
                                                                                                        || ' X.ACCOUNT_TYPE :='
                                                                                                        || x.account_type);

           /* IF X.ACCOUNT_TYPE = 'COBRA' THEN    --now
                --l_bank_acct_id := x.bank_acct_num;   -- Commented by Swamy for Ticket#11364
                IF upper(l_entity_type) = 'BROKER' THEN  -- Added by Swamy for Ticket#11364
                   l_bank_entity_id    := x.broker_id;
                   l_bank_entity_type  := upper(l_entity_type);
                ELSIF UPPER(l_entity_type) IN ('GA','GENERAL AGENT') THEN
                  l_bank_entity_id := X.ga_id;
                  l_bank_entity_type := 'GA';
                ELSE
                  l_bank_entity_type := 'ACCOUNT';
                  l_bank_entity_id := x.acc_id;
                END IF;
            ELSIF X.ACCOUNT_TYPE IN ('FSA','HRA') THEN    --now
                IF upper(l_entity_type) = 'BROKER' THEN   -- If Cond. for Broker Added by Swamy for Ticket#9719
                        l_bank_entity_id    := x.broker_id;
                        l_bank_entity_type  := upper(l_entity_type);
                ELSE
                   --   l_bank_acct_id := x.bank_acct_num; AND  --Commented by Joshi for 11493
                     -- For FSA/HRA, for enrollment, the entity type is hard coded to ACCOUNT, but again for resubmit functionality its differently coded.
                     l_bank_entity_type := 'ACCOUNT';
                     l_bank_entity_id := x.acc_id;
                END IF;
            ELSE

                IF UPPER(l_entity_type) = 'BROKER' THEN
                  l_bank_entity_id := X.broker_id;
                  l_bank_entity_type := 'BROKER';
                ELSIF UPPER(l_entity_type) IN ('GA','GENERAL AGENT') THEN
                  l_bank_entity_id := X.ga_id;
                  l_bank_entity_type := 'GA';
                ELSE
                   l_bank_entity_id := X.acc_id;
                   l_bank_entity_type := 'ACCOUNT';
                END IF;
            END IF;
            */

                    if x.account_type in ( 'COBRA', 'FSA', 'HRA', 'ERISA_WRAP' ) then   -- Erisa_wrap added by Swamy for Ticekt#11533
                        if upper(x.pay_acct_fees) = 'EMPLOYER' then
                            l_bank_entity_id := x.acc_id;
                            l_bank_entity_type := 'ACCOUNT';
                        elsif upper(x.pay_acct_fees) = 'BROKER' then
                            l_bank_entity_id := pc_account.get_broker_id(x.acc_id);
                            l_bank_entity_type := 'BROKER';
                        elsif upper(x.pay_acct_fees) = 'GA' then
                            l_bank_entity_id := pc_account.get_ga_id(x.acc_id);
                            l_bank_entity_type := 'GA';
                        end if;
                    else
                        if upper(l_entity_type) = 'BROKER' then
                            l_bank_entity_id := x.broker_id;
                            l_bank_entity_type := 'BROKER';
                        elsif upper(l_entity_type) in ( 'GA', 'GENERAL AGENT' ) then
                            l_bank_entity_id := x.ga_id;
                            l_bank_entity_type := 'GA';
                        else
                            l_bank_entity_id := x.acc_id;
                            l_bank_entity_type := 'ACCOUNT';
                        end if;
                    end if;

                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice **1 ', 'l_bank_entity_id '
                                                                                             || l_bank_entity_id
                                                                                             || ' x.bank_acct_num :='
                                                                                             || x.bank_acct_num);
            -- Added IF clause for ticket #11317 by Joshi
                    if
                        l_bank_entity_type is not null
                        and l_bank_entity_id is not null
                    then
                        for b in (
                            select
                                bank_acct_id
                            from
                                bank_accounts
                            where
                                    bank_acct_num = nvl(x.bank_acct_num, bank_acct_num)
                                and entity_id = l_bank_entity_id
                                and entity_type = l_bank_entity_type
                                and status = 'A'
                                and bank_account_usage = 'INVOICE'
                        ) loop
                            l_bank_acct_id := b.bank_acct_id;
                        end loop;

                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice **1 ', 'l_bank_acct_id ' || l_bank_acct_id)
                        ;
                        if
                            nvl(l_bank_acct_id, 0) = 0
                            and x.account_type <> 'COBRA'
                        then    -- And Cond added by Swamy for Ticket#12534
                            for c in (
                                select
                                    bank_acct_id
                                from
                                    bank_accounts
                                where
                                        bank_acct_num = nvl(x.bank_acct_num, bank_acct_num)
                                    and entity_id = l_bank_entity_id
                                    and entity_type = l_bank_entity_type
                                    and status = 'A'
                            ) loop
                                l_bank_acct_id := c.bank_acct_id;
                            end loop;
                        end if;

                        if l_bank_acct_id is null then
                            l_payment_method := 'ACH_PUSH';
                            l_bank_acct_id := null;
                            l_payment_term := 'NET15';
                            l_auto_pay := 'N';
                        end if;

                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice **1 ', 'l_payment_method ' || l_payment_method
                        );
                    end if; -- 11317 by Joshi
                else
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'in the ACH_PUSH loop');
                    l_payment_method := x.payment_method;
                    l_bank_acct_id := null;
                    l_payment_term := 'NET15';
                    l_auto_pay := 'N';
                end if;

                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice: l_payment_method ', l_payment_method);
                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_inv_param_id '
                                                                                    || l_inv_param_id
                                                                                    || 'l_payment_term :='
                                                                                    || l_payment_term
                                                                                    || 'l_auto_pay :='
                                                                                    || l_auto_pay
                                                                                    || 'l_bank_acct_id :='
                                                                                    || l_bank_acct_id);

                update invoice_parameters
                set
                    payment_method = nvl(l_payment_method, payment_method),
                    payment_term = l_payment_term,
                    autopay = l_auto_pay,
                    bank_acct_id = l_bank_acct_id,
                    invoice_frequency = l_invoice_frequency
                where
                    invoice_param_id = l_inv_param_id;

                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice update count ', sql%rowcount);
                for plan_id in (
                    select
                        r.rate_plan_id
                    from
                        rate_plans         r,
                        invoice_parameters ip
                    where
                            ip.entity_id = x.entrp_id
                        and r.entity_id = ip.entity_id
                        and ip.entity_type = 'EMPLOYER'
                        and r.rate_plan_id = ip.rate_plan_id
                        and ip.status = 'A'
                        and ip.invoice_type = 'FEE'
                ) loop
                    l_rate_plan_id := plan_id.rate_plan_id;
                end loop;

                if
                    x.account_type in ( 'POP', 'COBRA', 'ERISA_WRAP', 'FORM_5500' )
                    and l_inv_param_id is not null
                then   -- now

                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_rate_plan_id ' || l_rate_plan_id);
                    for rp in (
                        select distinct
                            arl.line_list_price total_quote_price,
                            rpd.rate_code,
                            pr.reason_name,
                            arh.ben_plan_number
                        from
                            ar_quote_headers arh,
                            ar_quote_lines   arl,
                            rate_plan_detail rpd,
                            pay_reason       pr,
                            rate_plans       rp
                        where
                                arh.quote_header_id = x.quote_header_id
                            and arh.entrp_id = x.entrp_id
                            and rp.rate_plan_id = arl.rate_plan_id
                            and arh.quote_header_id = arl.quote_header_id
                            and rp.rate_plan_id = rpd.rate_plan_id
                            and arl.rate_plan_detail_id = rpd.rate_plan_detail_id
                            and rpd.rate_code = pr.reason_code
                            and arl.line_list_price <> 0
                            and x.account_type <> ' POP'
                        union     -- now
                        select
                            l_cobra_monthly_admin_fee,
                            '183',
                            'COBRA Monthly Processing Fee',
                            null ben_plan_number  -- replaced hard coded value by joshi for 11998.
                        from
                            ar_quote_headers arh,
                            ar_quote_lines   arl,
                            rate_plan_detail rpd,
                            pay_reason       pr,
                            rate_plans       rp
                        where
                                arh.quote_header_id = x.quote_header_id
                            and arh.entrp_id = x.entrp_id
                            and rp.rate_plan_id = arl.rate_plan_id
                            and arh.quote_header_id = arl.quote_header_id
                            and rp.rate_plan_id = rpd.rate_plan_id
                            and arl.rate_plan_detail_id = rpd.rate_plan_detail_id
                            and rpd.rate_code = pr.reason_code
                            and rpd.rate_code = pr.reason_code
                            and rpd.rate_code = 182
                            and nvl(arl.line_list_price, 0) > 0 -- Added by Joshi for #11468
                            and x.account_type = 'COBRA'
                        union
                        select
                            arh.total_quote_price,
                            '30'          rate_code,
                            'Renewal Fee' reason_name,
                            null          ben_plan_number
                        from
                            ar_quote_headers arh
                        where
                                arh.quote_header_id = x.quote_header_id
                            and arh.entrp_id = x.entrp_id
                            and x.account_type = 'POP'
                    ) loop
                        l_description := null;
                        l_fee := rp.total_quote_price;
                        l_rate_code := rp.rate_code;
                        if x.account_type in ( 'POP', 'ERISA_WRAP' ) then
                            l_description := null;
                            pc_invoice.get_description(
                                p_account_type    => x.account_type,
                                p_acc_id          => x.acc_id,
                                p_source          => x.source,
                                p_ben_plan_id     => x.renewed_plan_id,
                                p_ben_plan_number => rp.ben_plan_number,
                                p_plan_type       => l_plan_type
                            );

                            l_description := l_plan_type;
                        elsif x.account_type = 'FORM_5500' then
                            l_description := null;
                            pc_invoice.get_description(
                                p_account_type    => x.account_type,
                                p_acc_id          => x.acc_id,
                                p_source          => x.source,
                                p_ben_plan_id     => x.renewed_plan_id,
                                p_ben_plan_number => rp.ben_plan_number,
                                p_plan_type       => l_plan_type
                            );

                            l_description := l_plan_type;
                            if rp.rate_code <> 62 then
                                l_description := 'Health and Welfare Form 5500 - Plan ' || l_plan_type;
                            else
                                l_description := 'Health and Welfare Form 5500 - Plan '
                                                 || l_plan_type
                                                 || '-'
                                                 || ' Final Filing';
                            end if;

                        end if;

                        if
                            x.account_type = 'ERISA_WRAP'
                            and rp.rate_code = '100'
                        then
                            l_rate_code := 30;
                        elsif x.account_type = 'FORM_5500' then
                            l_rate_code := 30;
                        end if;

                        if
                            x.account_type = 'COBRA'
                            and ( rp.rate_code = '30'
                            or rp.rate_code = '182' )
                        then
                            if rp.rate_code = '30' then
                                l_description := 'COBRA';
                            elsif rp.rate_code = '182' then
                                l_fee := rp.total_quote_price - 5;
                            end if;
                        end if;

                        pc_log.log_error('PC_INVOICE.INSERT_RATE_PLAN_DETAIL', 'l_fee '
                                                                               || l_fee
                                                                               || 'X.QUOTE_HEADER_ID :='
                                                                               || x.quote_header_id
                                                                               || 'rp.rate_code :='
                                                                               || rp.rate_code);

                        if nvl(l_fee, 0) <> 0 then
                            pc_log.log_error('PC_INVOICE.INSERT_RATE_PLAN_DETAIL', 'RP.REASON_NAME '
                                                                                   || rp.reason_name
                                                                                   || 'X.QUOTE_HEADER_ID :='
                                                                                   || x.quote_header_id);

                            pc_invoice.insert_rate_plan_detail(
                                p_rate_plan_id       => l_rate_plan_id,
                                p_calculation_type   => 'AMOUNT',
                                p_minimum_range      => null,
                                p_maximum_range      => null,
                                p_description        => l_description,
                                p_rate_code          => l_rate_code,
                                p_rate_plan_cost     => l_fee,
                                p_rate_basis         => 'FLAT_FEE',
                                p_effective_date     => x.plan_start_date, --SYSDATE,
                                p_effective_end_date => null, --SYSDATE,
                                p_one_time_flag      =>
                                                 case
                                                     when l_rate_code in(182, 183, 184)
                                                          and x.billing_frequency = 'MONTHLY' then
                                                         'N'
                                                     else
                                                         'Y'
                                                 end,
                                p_invoice_param_id   => l_inv_param_id,
                                p_user_id            => 0,
                                p_charged_to         => x.pay_acct_fees   -- added by swamy for ticket#11119
                            );

                            pc_log.log_error('PC_INVOICE.INSERT_RATE_PLAN_DETAIL', 'RP.l_inv_param_id ' || l_inv_param_id);
                        end if;

                    end loop;

                elsif x.account_type in ( 'FSA', 'HRA' ) then   -- entire esle now

   --    IF X.ACCOUNT_TYPE IN ('FSA','HRA') THEN
                    l_ndt_comprehensive := 'N';
                    if x.account_type = 'FSA' then
                        for ndt in (
                            select
                                ndt_preference
                            from
                                account_preference
                            where
                                    upper(ndt_preference) = 'COMPREHENSIVE'
                                and acc_id = x.acc_id
                        ) loop
                            if ndt.ndt_preference = 'COMPREHENSIVE' then
                                l_ndt_comprehensive := 'Y';
                            end if;
                        end loop;

                    end if;
        /*
        FOR P IN ( SELECT LISTAGG(plan_type, ',') WITHIN GROUP (ORDER BY acc_id)  plan_list
                     FROM ben_plan_renewals  WHERE acc_id = x.acc_id and trunc(creation_date) = trunc(sysdate))
        LOOP*/

                    for p in (
                        select
                            product_type,
                            listagg(plan_type, ',') within group(
                            order by
                                product_type
                            ) plan_list
                        from
                            (
                                select
                                    pc_lookups.get_meaning(bp.plan_type, 'FSA_HRA_PRODUCT_MAP') product_type,
                                    bp.plan_type
                                from
                                    ben_plan_enrollment_setup bp,
                                    ben_plan_renewals         br
                                where
                                        bp.acc_id = x.acc_id
                                    and pc_lookups.get_meaning(bp.plan_type, 'FSA_HRA_PRODUCT_MAP') = x.product_type
                              --  AND TRUNC(creation_date) = TRUNC(sysdate)
                              -- AND TRUNC(bp.creation_date) = TRUNC(sysdate)  - 1
                                    and trunc(add_business_days(7, bp.creation_date)) = trunc(sysdate)  -- Added by Joshi for 11636.
                                    and bp.acc_id = br.acc_id
                                    and bp.ben_plan_id = br.renewed_plan_id
                                    and trunc(bp.creation_date) = trunc(br.creation_date)
                                    and nvl(br.source, 'ONLINE') = 'ONLINE'  -- Added by Joshi for #11289
                                union
                                select
                                    pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') product_type,
                                    plan_type
                                from
                                    ben_plan_renewals
                                where
                                        acc_id = x.acc_id
                                    and pc_lookups.get_meaning(plan_type, 'FSA_HRA_PRODUCT_MAP') = x.product_type
                                    and nvl(source, 'ONLINE') = 'ONLINE' -- Added by Joshi for #11289
                                 -- AND TRUNC(creation_date) = TRUNC(sysdate)
                               --  AND TRUNC(creation_date) = TRUNC(sysdate) - 1
                                    and trunc(add_business_days(7, creation_date)) = trunc(sysdate)  -- Added by Joshi for 11636.
                                    and plan_type in ( 'TRN', 'PKG', 'UA1' )
                                union /* -- Added by Joshi for #11289 */
                                select
                                    pc_lookups.get_meaning(ops.plan_type, 'FSA_HRA_PRODUCT_MAP') product_type,
                                    ops.plan_type
                                from
                                    online_fsa_hra_staging      os,
                                    online_fsa_hra_plan_staging ops
                                where
                                        os.batch_number = ops.batch_number
                                    and os.entrp_id = ops.entrp_id
                                    and pc_lookups.get_meaning(ops.plan_type, 'FSA_HRA_PRODUCT_MAP') = x.product_type
                                    and os.batch_number = x.staging_batch_number
                                    and os.entrp_id = x.entrp_id
                                    and nvl(ops.renewal_new_plan, 'N') = 'Y'
                                    and nvl(os.source, 'ENROLLEMNT') = 'RENEWAL'
                            )
                        group by
                            product_type
                    ) loop
                        if p.plan_list is not null then
                            l_fee := pc_plan.get_hra_fsa_fees(p.plan_list, x.entrp_id, 'RENEWAL_FEE', 'N', x.no_of_eligible);
                        end if;

                        if nvl(l_ndt_comprehensive, 'N') = 'Y' then
                            l_fee_ndt := pc_plan.get_hra_fsa_fees(p.plan_list, x.entrp_id, 'SETUP_FEE', 'Y', x.no_of_eligible);

                        end if;

                        pc_log.log_error('PC_INVOICE.INSERT_RATE_PLAN_DETAIL', 'l_fee_ndt '
                                                                               || l_fee_ndt
                                                                               || 'l_ndt_comprehensive :='
                                                                               || l_ndt_comprehensive);
                        pc_log.log_error('PC_INVOICE.INSERT_RATE_PLAN_DETAIL', 'l_fee_ndt '
                                                                               || l_fee_ndt
                                                                               || 'l_fee :='
                                                                               || l_fee
                                                                               || 'l_inv_param_id :='
                                                                               || l_inv_param_id);

                        for j in (
                            select
                                reason_code,
                                reason_name
                            from
                                pay_reason
                            where
                                    plan_type = p.product_type
                                and reason_mapping = 30
                                and upper(reason_name) like '%RENEWAL%'
                        ) loop
                            l_rate_code := j.reason_code;
                            l_reason_name := j.reason_name;
                        end loop;

                        l_description := null;
                        if nvl(l_fee, 0) <> 0 then
                            pc_invoice.insert_rate_plan_detail(
                                p_rate_plan_id       => l_rate_plan_id,
                                p_calculation_type   => 'AMOUNT',
                                p_minimum_range      => null,
                                p_maximum_range      => null,
                                p_description        => l_description,
                                p_rate_code          => l_rate_code,
                                p_rate_plan_cost     => l_fee,
                                p_rate_basis         => 'FLAT_FEE',
                                p_effective_date     => x.plan_start_date, --SYSDATE,
                                p_effective_end_date => null, --SYSDATE,
                                p_one_time_flag      => 'Y',
                                p_invoice_param_id   => l_inv_param_id,
                                p_user_id            => 0,
                                p_charged_to         => x.pay_acct_fees   -- added by swamy for ticket#11119
                            );
                        end if;

                        if nvl(l_ndt_comprehensive, 'N') = 'Y' then
                -- NDT inclusive fee - fees without NDT
                            l_fee_ndt := nvl(l_fee_ndt, 0) - nvl(l_fee, 0);
                            pc_log.log_error('PC_INVOICE.INSERT_RATE_PLAN_DETAIL', 'l_fee_ndt **1 '
                                                                                   || l_fee_ndt
                                                                                   || 'l_fee :='
                                                                                   || l_fee);
                            if nvl(l_fee_ndt, 0) > 0 then
                                pc_invoice.insert_rate_plan_detail(
                                    p_rate_plan_id       => l_rate_plan_id,
                                    p_calculation_type   => 'AMOUNT',
                                    p_minimum_range      => null,
                                    p_maximum_range      => null,
                                    p_description        => null,
                                    p_rate_code          =>
                                                 case
                                                     when p.product_type = 'FSA' then
                                                         269
                                                     else
                                                         270
                                                 end,
                                    p_rate_plan_cost     => l_fee_ndt,
                                    p_rate_basis         => 'FLAT_FEE',
                                    p_effective_date     => x.plan_start_date, --SYSDATE,
                                    p_effective_end_date => null, --SYSDATE,
                                    p_one_time_flag      => 'Y',
                                    p_invoice_param_id   => l_inv_param_id,
                                    p_user_id            => 0,
                                    p_charged_to         => x.pay_acct_fees   -- added by swamy for ticket#11119
                                );
                            end if;

                        end if;

           /* commented by Joshi for #11359. should be called after generating invoice.
            -- For setup/Renewal FSA/HRA invoices
            pc_invoice.INSERT_FSA_HRA_MONTHLY_RATE_LINES( P_ENTRP_ID         => X.entrp_id
                                                        , P_RATE_PLAN_ID     => l_rate_plan_id
                                                        , P_INVOICE_PARAM_ID => l_inv_param_id
                                                        , p_source           => x.source
                                                        , P_BATCH_NUMBER     => p_batch_number);
            */
                    end loop;

                end if;

    -- populate discount rate line lines
                if
                    x.product_type = 'HRA'
                    and pc_account.is_stacked_account_new(x.entrp_id) = 'Y'
                then
                    null;
                else
                    pc_invoice.insert_discount_rate_lines(
                        p_batch_number     => x.batch_number,
                        p_entrp_id         => x.entrp_id,
                        p_quote_header_id  => x.quote_header_id,
                        p_rate_plan_id     => l_rate_plan_id,
                        p_invoice_param_id => l_inv_param_id,
                        p_source           => x.source,
                        p_fee              => l_fee
                    );
                end if;

                if x.account_type = 'COBRA' then

        -- added by swamy for ticket#11262
                    l_opt_fee_bank_acct_id := null;
                    l_opt_fee_payment_method := null;
                    l_opt_fee_autopay := null;
                    l_opt_fee_payment_term := null;
                    l_payment_method := null;
                    l_payment_term := null;
                    l_bank_acct_id := null;
                    l_auto_pay := null;
                    l_invoice_frequency := null;
                    pc_log.log_error('pc_invoice.Generate_daily_setup_renewal_invoice X.pay_acct_fees ', x.pay_acct_fees
                                                                                                         || ' x.MTH_OPT_FEE_PAID_BY :='
                                                                                                         || x.mth_opt_fee_paid_by);

                    l_opt_fee_invoice_generated := 'N';
                    for i in (
                        select
                            payment_method,
                            payment_term,
                            autopay,
                            bank_acct_id,
                            invoice_frequency
                        from
                            invoice_parameters
                        where
                            invoice_param_id = l_inv_param_id
                    ) loop
                        l_payment_method := i.payment_method;
                        l_payment_term := i.payment_term;
                        l_bank_acct_id := i.bank_acct_id;
                        l_auto_pay := i.autopay;
                        l_invoice_frequency := i.invoice_frequency;
                    end loop;

                    if upper(x.pay_acct_fees) <> upper(x.mth_opt_fee_paid_by) then
            -- generate optional services invoice first
            -- generate setup/renewal invoice second.
                        l_start_date := trunc(x.plan_start_date);
                        l_end_date := trunc(x.plan_end_date);

            --  update invoice parameter with option_fee_payment_method
              -- Added by Swamy for Ticket#12534
              -- Check if the optional fee bank is in Active status.
                        l_active_bank_exists := 'N';
                        for j in (
                            select
                                'Y' chk_bank
                            from
                                bank_accounts
                            where
                                    bank_acct_id = x.mth_opt_fee_bank_acct_id
                                and status = 'A'
                        ) loop
                            l_active_bank_exists := j.chk_bank;
                        end loop;

                        if
                            x.mth_opt_fee_bank_acct_id is not null
                            and nvl(l_active_bank_exists, 'N') = 'Y'
                        then
                            l_opt_fee_bank_acct_id := x.mth_opt_fee_bank_acct_id;
                            l_opt_fee_payment_method := 'DIRECT_DEPOSIT';
                            l_opt_fee_autopay := 'Y';
                            l_opt_fee_payment_term := 'IMMEDIATE';
                        else
                            l_opt_fee_bank_acct_id := null;
                            l_opt_fee_payment_method := 'ACH_PUSH';
                            l_opt_fee_autopay := 'N';   -- added by Joshi for 11673
                            l_opt_fee_payment_term := 'NET15';
                        end if;

                        update invoice_parameters
                        set
                            payment_method = l_opt_fee_payment_method,
                            payment_term = l_opt_fee_payment_term,
                            autopay = l_opt_fee_autopay,
                            bank_acct_id = l_opt_fee_bank_acct_id,
                            invoice_frequency = 'ONCE'
                        where
                            invoice_param_id = l_inv_param_id;

            -- update rate plan detail effective end date for monthlly or annual fee rate codes  to sysdate/l_end_date.
            -- 184 is cobra setup fees.
                        pc_log.log_error('**1 update  pc_invoice.Generate_daily_setup_renewal_invoice calling generate_invoic X.mth_opt_fee_paid_by '
                        , x.mth_opt_fee_paid_by);
                        update rate_plan_detail
                        set
                            effective_end_date = trunc(sysdate + 1)
                        where
                            effective_end_date is null
                            and invoice_param_id = l_inv_param_id
                            and rate_plan_id = l_rate_plan_id
                            and rate_code not in ( 86, 266, 54, 55 );

                        update rate_plan_detail
                        set
                            charged_to = upper(x.mth_opt_fee_paid_by)
                        where
                                invoice_param_id = l_inv_param_id
                            and rate_code in ( 86, 266, 54, 55 )
                            and rate_plan_id = l_rate_plan_id
                            and effective_end_date is null;

                        pc_log.log_error('**1 pc_invoice.Generate_daily_setup_renewal_invoice calling generate_invoic l_start_date ',
                        l_start_date
                                                                                                                                    || ' l_end_date :='
                                                                                                                                    || l_end_date
                                                                                                                                    || ' x.entrp_id :='
                                                                                                                                    || x.entrp_id
                                                                                                                                    || 'x.account_type :='
                                                                                                                                    || x.account_type
                                                                                                                                    || 'X.Billing_frequency :='
                                                                                                                                    || x.billing_frequency
                                                                                                                                    || 'l_invoice_batch_number :='
                                                                                                                                    || l_invoice_batch_number
                                                                                                                                    || ' l_inv_param_id :='
                                                                                                                                    || l_inv_param_id
                                                                                                                                    || ' l_rate_plan_id :='
                                                                                                                                    || l_rate_plan_id
                                                                                                                                    )
                                                                                                                                    ;

                        pc_invoice.generate_invoice(l_start_date, l_end_date, sysdate, x.entrp_id, x.account_type,
                                                    x_error_status, x_error_message, 'ONCE', null, l_invoice_batch_number);

                        l_opt_fee_invoice_generated := 'Y';
            --
                        if nvl(x_error_status, 'S') = 'S' then
                            pc_log.log_error('**2 update  pc_invoice.Generate_daily_setup_renewal_invoice calling generate_invoic X.pay_acct_fees '
                            , x.pay_acct_fees); --update rate_plan_detail to remove the effective end date for Setup/Monthly fee.
                            update rate_plan_detail
                            set
                                effective_end_date = null
                            where
                                    invoice_param_id = l_inv_param_id
                                and rate_code not in ( 86, 266, 54, 55 )
                                and rate_plan_id = l_rate_plan_id
                                and effective_end_date = trunc(sysdate + 1);

                            update rate_plan_detail
                            set
                                effective_end_date = x.plan_start_date,
                                charged_to = upper(x.mth_opt_fee_paid_by)
                            where
                                    invoice_param_id = l_inv_param_id
                                and trunc(effective_end_date) = trunc(sysdate)
                                and rate_code in ( 86, 266, 54, 55 )
                                and rate_plan_id = l_rate_plan_id;

                        end if;

           --  update invoice parameter with Setup/renewal fee payment details.
                        update invoice_parameters
                        set
                            payment_method = l_payment_method,
                            payment_term = l_payment_term,
                            autopay = l_auto_pay,
                            bank_acct_id = l_bank_acct_id,
                            invoice_frequency = x.billing_frequency
                        where
                            invoice_param_id = l_inv_param_id;

       -- PC_INVOICE.generate_invoice(l_start_date,l_end_date,sysdate,x.entrp_id,x.account_type,x_error_status,x_error_message,X.Billing_frequency,null,l_invoice_batch_number);
                    end if;
        -- ending 11262
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice cobra x.billing_frequency :', x.billing_frequency
                                                                                                                    || 'l_inv_param_id :='
                                                                                                                    || l_inv_param_id
                                                                                                                    || 'x.plan_start_date :='
                                                                                                                    || x.plan_start_date
                                                                                                                    );

                    if x.billing_frequency = 'MONTHLY' then

         -- Added by Joshi for 11294.
                        for ip in (
                            select
                                payment_method,
                                payment_term,
                                autopay,
                                bank_acct_id
                            from
                                invoice_parameters
                            where
                                invoice_param_id = l_inv_param_id
                        ) loop
                            populate_monthly_inv_payment_dtl(
                                p_entrp_id        => x.entrp_id,
                                p_source          => x.source,
                                p_payment_method  => ip.payment_method,
                                p_bank_acct_id    => ip.bank_acct_id,
                                p_charged_to      => x.pay_acct_fees,
                                p_plan_start_date => x.plan_start_date,
                                p_plan_end_date   => x.plan_end_date,
                                p_user_id         => 0
                            );
                        end loop;
         --code ends here Joshi for 11294.

                        for n in (
                            select
                                period_start_date,
                                period_end_date,
                                no_of_period
                            from
                                (
                                    select
                                        add_months(
                                            trunc(x.plan_start_date, 'MM'),
                                            level - 1
                                        )     period_start_date,
                                        last_day(add_months(
                                            trunc(x.plan_start_date, 'MM'),
                                            level - 1
                                        ))    period_end_date,
                                        level no_of_period
                                    from
                                        dual
                                    connect by
                                        level <= ( abs(months_between(sysdate, x.plan_start_date)) + 2 )
                                )
                            where
                                trunc(period_start_date) <= trunc(sysdate)
                        ) loop
                            l_start_date := n.period_start_date;
                            l_end_date := n.period_end_date;
                            pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice cobra start and end dates :', l_start_date
                                                                                                                            || ':'
                                                                                                                            || l_end_date
                                                                                                                            || ' n.no_of_period :='
                                                                                                                            || n.no_of_period
                                                                                                                            );

                            pc_invoice.generate_invoice(l_start_date, l_end_date, sysdate, x.entrp_id, x.account_type,
                                                        x_error_status, x_error_message, x.billing_frequency, null, l_invoice_batch_number
                                                        );

                            if n.no_of_period = 1 then
                                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice cobra updat rate-plan_details end dates :'
                                , l_end_date);
               -- rate plan line should be end dated for optional service  after first run to avoid adding them in the consecutive
               -- generation
                                update rate_plan_detail
                                set
                                    effective_end_date = trunc(l_end_date)
                                where
                                        rate_plan_id = l_rate_plan_id
                                    and one_time_flag = 'Y'
                                    and trunc(effective_end_date) = trunc(sysdate)
                                    and rate_code not in ( 182, 183, 184, 264 );

                            end if;

                        end loop;

                    else
                        l_start_date := trunc(x.plan_start_date);
                        l_end_date := trunc(x.plan_end_date);
                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice cobra calling generate_invoice **2 start and end dates :'
                        , l_start_date
                                                                                                                                                   || ':'
                                                                                                                                                   || l_end_date
                                                                                                                                                   )
                                                                                                                                                   ;
                        pc_invoice.generate_invoice(l_start_date, l_end_date, sysdate, x.entrp_id, x.account_type,
                                                    x_error_status, x_error_message, x.billing_frequency, null, l_invoice_batch_number
                                                    );

                    end if;

       -- Added by Joshi for #11294.
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_exist_payment_method '
                                                                                        || l_exist_payment_method
                                                                                        || 'l_payment_method: '
                                                                                        || l_payment_method);
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_exist_invoice_frequency '
                                                                                        || l_exist_invoice_frequency
                                                                                        || 'l_invoice_frequency: '
                                                                                        || l_invoice_frequency);
                    if
                        nvl(l_exist_invoice_frequency, 'ONCE') = 'MONTHLY'
                        and nvl(l_invoice_frequency, 'ONCE') <> 'MONTHLY'
                        and trunc(sysdate) < trunc(x.plan_start_date)
                    then
                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'inside updating the old paymen details l_inv_param_id: ' || l_inv_param_id
                        );
                        update invoice_parameters
                        set
                            payment_method = l_exist_payment_method,
                            invoice_frequency = l_exist_invoice_frequency,
                            payment_term = l_exist_payment_term,
                            autopay = l_exist_auto_pay,
                            bank_acct_id = l_exist_bank_acct_id
                        where
                            invoice_param_id = l_inv_param_id;

                    end if;

                elsif x.account_type in ( 'FSA', 'HRA' ) then
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'inside fsa/hra l_invoice_batch_number: ' || l_invoice_batch_number
                    );
                    pc_invoice.generate_invoice(
                        trunc(x.plan_start_date),
                        trunc(x.plan_end_date),
                        sysdate,
                        x.entrp_id,
                        x.account_type,
                        x_error_status,
                        x_error_message,
                        'RENEWAL',
                        null,
                        l_invoice_batch_number
                    );

                else
                    pc_invoice.generate_invoice(
                        trunc(x.plan_start_date),
                        trunc(x.plan_end_date),
                        sysdate,
                        x.entrp_id,
                        x.account_type,
                        x_error_status,
                        x_error_message,
                        x.billing_frequency,
                        null,
                        l_invoice_batch_number
                    );
                end if;

                if nvl(x_error_status, '*') = 'E' then
                    raise erreur;
                end if;

    --PC_INVOICE.generate_invoice(TRUNC(TRUNC(SYSDATE,'MM')-1,'MM'),LAST_DAY(TRUNC(SYSDATE,'MM')-1),NULL,x.entrp_id,x.account_type,x_error_status,x_error_message,'MONTHLY',X.Billing_frequency,l_invoice_batch_number);
                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_invoice_batch_number ' || l_invoice_batch_number
                );
                for j in (
                    select
                        invoice_id
                    from
                        ar_invoice
                    where
                            entity_id = x.entrp_id
                        and entity_type = 'EMPLOYER'
                        and trunc(creation_date) = trunc(sysdate)
                        and batch_number = l_invoice_batch_number
                ) loop
                    update daily_enroll_renewal_account_info a
                    set
                        invoice_id = j.invoice_id,
                        error_status = 'S'
                    where
                            a.batch_number = p_batch_number
                        and a.source = 'RENEWAL'
                        and invoice_id is null
                        and product_type = x.product_type
                        and a.entrp_id = x.entrp_id
                        and ( x.quote_header_id is null
                              or ( x.quote_header_id is not null
                                   and a.quote_header_id = x.quote_header_id ) );

                end loop;

      -- Insert monthly maintainence rate line items.
                if x.account_type in ( 'FSA', 'HRA' ) then
       -- For setup/Renewal FSA/HRA invoices , the rate plans end date should be set to plan start date.
       -- so that they these rate lines are included in monthly invoice.
                    update rate_plan_detail
                    set
                        effective_end_date = trunc(x.plan_start_date)
                    where
                            rate_plan_id = l_rate_plan_id
                        and one_time_flag = 'Y'
                        and trunc(effective_end_date) = trunc(x.plan_end_date);

                    pc_invoice.insert_fsa_hra_monthly_rate_lines(
                        p_entrp_id         => x.entrp_id,
                        p_rate_plan_id     => l_rate_plan_id,
                        p_invoice_param_id => l_inv_param_id,
                        p_source           => x.source,
                        p_batch_number     => p_batch_number
                    );

    -- for form_5500 if there are more then one plan, then the second plan's invoice will include the first plans amount from rate plan detail, hence making the effective_date date as plan start date.
    -- Added by swamy for Ticket#11708
                elsif x.account_type in ( 'FORM_5500' ) then
                    update rate_plan_detail
                    set
                        effective_end_date = trunc(x.plan_start_date)
                    where
                            rate_plan_id = l_rate_plan_id
                        and one_time_flag = 'Y'
                        and trunc(effective_date) = trunc(x.plan_start_date)
                        and effective_end_date is null;

                end if;

            exception
                when erreur then
                    update daily_enroll_renewal_account_info a
                    set
                        error_status = 'E',
                        error_message = x_error_message
                    where
                            a.batch_number = p_batch_number
                        and a.source = 'RENEWAL'
                        and entrp_id = x.entrp_id;

                when others then
                    x_error_message := substr(sqlerrm, 1, 200);
                    update daily_enroll_renewal_account_info a
                    set
                        error_status = 'E',
                        error_message = x_error_message || dbms_utility.format_error_backtrace
                    where
                            a.batch_number = p_batch_number
                        and a.source = 'RENEWAL'
                        and entrp_id = x.entrp_id;

            end;
        end loop;

        pc_notifications.daily_setup_renewal_invoice_notify(
            p_batch_number => p_batch_number,
            p_source       => 'RENEWAL'
        );
    exception
        when others then
            pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice others', 'l_invoice_batch_number '
                                                                                       || l_invoice_batch_number
                                                                                       || 'error :='
                                                                                       || sqlerrm);
    end generate_daily_renewal_invoice;

-- Added by Joshi for Ticket#11119
    procedure generate_daily_setup_invoice (
        p_batch_number in number,
        p_entrp_id     in number default null
    ) is

        l_rate_plan_id              number;
        l_inv_param_id              number;
        l_bank_acct_id              number;
        l_payment_method            varchar2(100);
        l_rate_code                 number;
        l_reason_name               varchar2(250);
        l_fee                       number;
        x_error_status              varchar2(1);
        x_error_message             varchar2(4000);
        l_invoice_batch_number      number;
        lc_rate_plan_id             number;
        l_description               varchar2(250);
        l_bank_entity_type          varchar2(50);
        l_bank_entity_id            number;
        l_entrp_name                varchar2(500);
        erreur exception;
        l_user_type                 varchar2(5);
        l_enrolled_by               number;
        l_entity_type               varchar2(20);
        l_broker_id                 number;
        l_tax_rate                  number;
        l_state                     varchar2(2);
        l_city                      varchar2(30);
        l_plan_type                 varchar2(30);
        l_plan_number               varchar2(50);
        l_plan_list                 varchar2(4000);
        l_rate_fee                  number;
        l_end_date                  date;
        l_start_date                date;
        l_fee_ndt                   number;
        l_ndt_comprehensive         varchar2(1);
        l_rate_line_cnt             number;
        l_charged_to                varchar2(20);
        l_auto_pay                  varchar2(1);
        l_payment_term              varchar2(20);
        l_opt_fee_bank_acct_id      number;
        l_opt_fee_payment_method    varchar2(50);
        l_opt_fee_autopay           varchar2(1);
        l_opt_fee_payment_term      varchar2(50);
        l_opt_fee_invoice_generated varchar2(1) := 'N';
        l_cobra_monthly_admin_fee   number;    --- Added by Joshi for 11998
        l_bank_acct_id_opt          number; -- Added by Swamy for Ticket#12534
    begin

--Added by Joshi for 11998
        l_cobra_monthly_admin_fee := pc_invoice.get_cobra_monthly_admin_fee;
        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'before loop ' || p_batch_number);
        for x in (
            select
                *
            from
                daily_enroll_renewal_account_info
            where
                    batch_number = p_batch_number
                and source = 'SETUP'
                and invoice_id is null
            order by
                acc_id,
                plan_start_date
        )  -- Order by Clause Added by Swamy for Ticket#11708
         loop
            begin
    -- Setup rate plans for new enroll groups.
    --l_rate_plan_id := RATE_PLANS_SEQ.NEXTVAL;
                lc_rate_plan_id := 0;
                l_inv_param_id := 0;
                l_entrp_name := null;
                l_bank_entity_id := null;            -- 11263
                l_bank_entity_type := null;         -- 11263
                l_bank_acct_id := null;              -- 11263
                l_entrp_name := pc_entrp.get_entrp_name(x.entrp_id);
                for m in (
                    select
                        rate_plan_id
                    from
                        rate_plans
                    where
                            entity_id = x.entrp_id
                        and status = 'A'
                        and rate_plan_type = 'INVOICE'
                ) loop
                    lc_rate_plan_id := m.rate_plan_id;
                    l_rate_plan_id := m.rate_plan_id;
                end loop;

                if nvl(lc_rate_plan_id, 0) = 0 then
                    l_rate_plan_id := rate_plans_seq.nextval;
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', ' INSERT INTO RATE_PLANS' || x.entrp_id);
                    insert into rate_plans (
                        rate_plan_id,
                        rate_plan_name,
                        entity_type,
                        entity_id,
                        status,
                        note,
                        effective_date,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        rate_plan_type
                    ) values ( l_rate_plan_id,
                               l_entrp_name,
                               'EMPLOYER',
                               x.entrp_id,
                               'A',
                               'Setup Invoice',
                               x.plan_start_date,
                               sysdate,
                               0,
                               sysdate,
                               0,
                               'INVOICE' ) returning rate_plan_id into lc_rate_plan_id;

                end if;

                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'lc_rate_plan_id ' || lc_rate_plan_id);
                if nvl(lc_rate_plan_id, 0) = 0 then
                    update daily_enroll_renewal_account_info a
                    set
                        error_status = 'E',
                        error_message = ' Failed to Insert into Rate plan table'
                    where
                            a.batch_number = p_batch_number
                        and a.source = 'SETUP'
                        and entrp_id = x.entrp_id;

                end if;

                l_bank_acct_id := null;
                if upper(x.payment_method) = 'ACH' then
                    l_payment_method := 'DIRECT_DEPOSIT';
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'x.account_type '
                                                                                        || x.account_type
                                                                                        || 'X.pay_acct_fees :='
                                                                                        || x.pay_acct_fees);

       -- Added by Joshi for 11262
      --   IF x.account_type = 'COBRA' THEN
                    if x.account_type in ( 'COBRA', 'ERISA_WRAP', 'FORM_5500', 'POP' ) then -- commented above added by Joshi for 12279
                        if nvl(x.pay_acct_fees, 'EMPLOYER') = 'EMPLOYER' then
                            l_bank_entity_type := 'ACCOUNT';
                            l_bank_entity_id := x.acc_id;
                        elsif nvl(x.pay_acct_fees, 'EMPLOYER') = 'BROKER' then
                            l_bank_entity_id := x.broker_id;
                            l_bank_entity_type := 'BROKER';
                        elsif nvl(x.pay_acct_fees, 'EMPLOYER') = 'GA' then
                            l_bank_entity_id := x.ga_id;
                            l_bank_entity_type := 'GA';
                        end if;

                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_bank_entity_id '
                                                                                            || l_bank_entity_id
                                                                                            || 'l_bank_entity_type :='
                                                                                            || l_bank_entity_type
                                                                                            || 'x.bank_acct_num :='
                                                                                            || x.bank_acct_num);
     /* commented by Joshi for 12279  
      ELSIF x.account_type IN ('ERISA_WRAP','FORM_5500','POP') THEN
        IF x.Enrolle_Type = 'BROKER' THEN   -- If Cond. for Broker Added by Swamy for Ticket#9719
            IF nvl(X.pay_acct_fees,'EMPLOYER') = 'EMPLOYER'  THEN   -- 9412 rprabu 31/08/2020
                l_bank_entity_id    := x.acc_Id;
                l_bank_entity_type  := 'ACCOUNT';
            ELSIF X.pay_acct_fees = 'BROKER' Then
                l_bank_entity_id    := x.broker_id;
                l_bank_entity_type  := x.Enrolle_Type;
            END IF;
        ELSIF x.Enrolle_Type = 'GA' THEN
            IF nvl(X.pay_acct_fees,'EMPLOYER')    in  ( 'EMPLOYER', 'BROKER') THEN -- 9412 rprabu 31/08/2020
                l_bank_entity_id    := x.acc_Id;
                l_bank_entity_type  := 'ACCOUNT';
            ELSIF X.pay_acct_fees IN ('GA'  )   THEN
                l_bank_entity_id    := x.ga_id;
                l_bank_entity_type  := x.Enrolle_Type;
            END IF;
        ELSE -- For employer, bank account should go as employer irrespecive of who pays.
            l_bank_entity_id    := x.acc_Id;
            l_bank_entity_type  := 'ACCOUNT';
        END IF;
         comment ends here Joshi for 12279 */
                    elsif x.account_type in ( 'FSA', 'HRA' ) then    --now
                        if nvl(x.pay_acct_fees, 'EMPLOYER') = 'EMPLOYER' then
                            l_bank_entity_type := 'ACCOUNT';
                            l_bank_entity_id := x.acc_id;
                        elsif nvl(x.pay_acct_fees, 'EMPLOYER') = 'BROKER' then
                            l_bank_entity_id := x.broker_id;
                            l_bank_entity_type := 'BROKER';
                        end if;
                    end if;

                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_bank_entity_id '
                                                                                        || l_bank_entity_id
                                                                                        || 'l_bank_entity_type :='
                                                                                        || l_bank_entity_type
                                                                                        || 'x.bank_acct_num :='
                                                                                        || x.bank_acct_num);

                    for b in (
                        select
                            bank_acct_id
                        from
                            bank_accounts
                        where
                                bank_acct_num = nvl(x.bank_acct_num, bank_acct_num)
                            and entity_id = l_bank_entity_id
                            and entity_type = l_bank_entity_type
                            and status = 'A'
                            and bank_account_usage = 'INVOICE'
                    ) loop
                        l_bank_acct_id := b.bank_acct_id;
                    end loop;

                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_bank_acct_id:  ' || l_bank_acct_id);
                    if
                        nvl(l_bank_acct_id, 0) = 0
                        and x.account_type <> 'COBRA'
                    then   -- AND COnd Added by Swamy for Ticket#12534 

                        for c in (
                            select
                                bank_acct_id
                            from
                                bank_accounts
                            where
                                    bank_acct_num = nvl(x.bank_acct_num, bank_acct_num)
                                and entity_id = l_bank_entity_id
                                and entity_type = l_bank_entity_type
                                and status = 'A'
                        ) loop
                            l_bank_acct_id := c.bank_acct_id;
                        end loop;

                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_bank_acct_id:  ' || l_bank_acct_id);
                    end if;

            -- Added by Joshi 12269. if the bank account is not found, set the payment method to ACH_PUSH.
                    if l_bank_acct_id is null then
                        l_payment_method := 'ACH_PUSH';
                        l_bank_acct_id := null;
                    end if;
                else
                    l_payment_method := x.payment_method;
                end if;

                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'lc_rate_plan_id  **1 ' || lc_rate_plan_id);
                if nvl(lc_rate_plan_id, 0) <> 0 then
                    for h in (
                        select
                            invoice_param_id
                        from
                            invoice_parameters p
                        where
                                p.entity_id = x.entrp_id
                            and p.entity_type = 'EMPLOYER'
                            and p.invoice_type = 'FEE'
                    ) loop
                        l_inv_param_id := h.invoice_param_id;
                    end loop;

                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_rate_plan_id  **2 '
                                                                                        || l_rate_plan_id
                                                                                        || 'l_inv_param_id :='
                                                                                        || l_inv_param_id);
                    if nvl(l_inv_param_id, 0) = 0 then
                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_payment_method: '
                                                                                            || l_payment_method
                                                                                            || ' l_bank_acct_id := '
                                                                                            || l_bank_acct_id
                                                                                            || ' l_rate_plan_id := '
                                                                                            || l_rate_plan_id
                                                                                            || ' X.billing_frequency := '
                                                                                            || x.billing_frequency);

                        pc_invoice.setup_inv_parameter_for_employer(
                            p_entrp_id       => x.entrp_id,
                            p_batch_number   => p_batch_number,
                            p_payment_method => l_payment_method,
                            p_bank_acct_id   => l_bank_acct_id,
                            p_inv_frequency  => x.billing_frequency,
                            p_rate_plan_id   => l_rate_plan_id
                        );

                    elsif
                        l_inv_param_id is not null
                        and l_inv_param_id > 0
                    then -- Added by Joshi for 12283

                        if l_payment_method in ( 'ACH', 'DIRECT_DEPOSIT' ) then
                            l_payment_method := 'DIRECT_DEPOSIT';
                            l_payment_term := 'IMMEDIATE';
                            l_auto_pay := 'Y';
                        else
                            l_payment_term := 'NET15';
                            l_auto_pay := 'N';
                        end if;

                        update invoice_parameters
                        set
                            payment_method = l_payment_method,
                            payment_term = l_payment_term,
                            autopay = l_auto_pay,
                            bank_acct_id = l_bank_acct_id,
                            invoice_frequency = x.billing_frequency
                        where
                            invoice_param_id = l_inv_param_id;

                    end if;

                end if;

    --- fee calculation.
                for i in (
                    select
                        invoice_param_id
                    from
                        invoice_parameters
                    where
                            entity_id = x.entrp_id
                        and entity_type = 'EMPLOYER'
                        and status = 'A'
                        and invoice_type = 'FEE'
                ) loop
                    l_inv_param_id := i.invoice_param_id;
                end loop;

   -- dbms_output.put_line( 'l_inv_param_id:'     ||  l_inv_param_id);
   -- dbms_output.put_line( 'X.ACCOUNT_TYPE:' || X.ACCOUNT_TYPE);
   -- dbms_output.put_line( 'l_rate_plan_id:'      ||  l_rate_plan_id);

                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice', 'l_rate_plan_id  **2 '
                                                                                    || l_rate_plan_id
                                                                                    || 'l_inv_param_id :='
                                                                                    || l_inv_param_id);
                if
                    x.account_type in ( 'POP', 'COBRA', 'ERISA_WRAP' )
                    and l_inv_param_id is not null
                then

     --   dbms_output.put_line( 'In the compliance block');

                    for rp in (
                        select distinct
                            arl.line_list_price total_quote_price,
                            rpd.rate_code,
                            pr.reason_name
                        from
                            ar_quote_headers arh,
                            ar_quote_lines   arl,
                            rate_plan_detail rpd,
                            pay_reason       pr,
                            rate_plans       rp
                        where
                                arh.quote_header_id = x.quote_header_id
                            and arh.entrp_id = x.entrp_id
                            and rp.rate_plan_id = arl.rate_plan_id
                            and arh.quote_header_id = arl.quote_header_id
                            and rp.rate_plan_id = rpd.rate_plan_id
                            and arl.rate_plan_detail_id = rpd.rate_plan_detail_id
                            and rpd.rate_code = pr.reason_code
                            and x.account_type not in ( 'POP' )
                        union
                        select
                            l_cobra_monthly_admin_fee,
                            '183',
                            'COBRA Monthly Processing Fee'    -- replaced hardcoded value  Joshi for 11998.
                        from
                            ar_quote_headers arh,
                            ar_quote_lines   arl,
                            rate_plan_detail rpd,
                            pay_reason       pr,
                            rate_plans       rp
                        where
                                arh.quote_header_id = x.quote_header_id
                            and arh.entrp_id = x.entrp_id
                            and rp.rate_plan_id = arl.rate_plan_id
                            and arh.quote_header_id = arl.quote_header_id
                            and rp.rate_plan_id = rpd.rate_plan_id
                            and arl.rate_plan_detail_id = rpd.rate_plan_detail_id
                            and rpd.rate_code = pr.reason_code
                            and rpd.rate_code = pr.reason_code
                            and rpd.rate_code = 182
                            and nvl(arl.line_list_price, 0) > 0 -- Added by Joshi for #11468
                            and x.account_type = 'COBRA'
                        union
                        select
                            arh.total_quote_price,
                            '1'          rate_code,
                            'Set up fee' reason_name
                        from
                            ar_quote_headers arh
                        where
                                arh.quote_header_id = x.quote_header_id
                            and arh.entrp_id = x.entrp_id
                            and x.account_type in ( 'POP' )
                    ) loop
                        l_description := null;
                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice: REASON_NAME ', rp.reason_name);
         --    pc_invoice.get_description(p_account_type  => X.ACCOUNT_TYPE,p_acc_id  => x.acc_id,p_source => x.source,p_ben_plan_id => x.ben_plan_id, p_ben_plan_number => null,p_plan_type => l_plan_type) ;

                        if x.account_type <> 'COBRA' then
                            pc_invoice.get_description(
                                p_account_type    => x.account_type,
                                p_acc_id          => x.acc_id,
                                p_source          => x.source,
                                p_ben_plan_id     => x.ben_plan_id,
                                p_ben_plan_number => null,
                                p_plan_type       => l_plan_type
                            );

                            l_description := l_plan_type;
                        end if;

                        l_rate_code := rp.rate_code;
                        l_rate_fee := rp.total_quote_price;
                        if
                            x.account_type = 'COBRA'
                            and ( rp.rate_code = '30'
                            or rp.rate_code = '182' )
                        then
                            if rp.rate_code = '30' then
                                l_rate_code := 1;
                                l_description := 'COBRA';
                            elsif rp.rate_code = '182' then
                                l_rate_code := 184;
                                l_rate_fee := rp.total_quote_price - 5;
                            end if;
                        end if;

                        if
                            x.account_type = 'ERISA_WRAP'
                            and rp.rate_code = '1'
                        then
                            l_fee := rp.total_quote_price;
                        end if;

            -- l_description := l_plan_type;
                        if nvl(rp.total_quote_price, 0) <> 0 then
                            pc_invoice.insert_rate_plan_detail(
                                p_rate_plan_id       => l_rate_plan_id,
                                p_calculation_type   => 'AMOUNT',
                                p_minimum_range      => null,
                                p_maximum_range      => null,
                                p_description        => l_description,
                                p_rate_code          => l_rate_code,
                                p_rate_plan_cost     => l_rate_fee,  -- RP.TOTAL_QUOTE_PRICE,
                                p_rate_basis         => 'FLAT_FEE',
                                p_effective_date     => x.plan_start_date, --SYSDATE,
                                p_effective_end_date => null, --SYSDATE,
                                p_one_time_flag      =>
                                                 case
                                                     when l_rate_code in(182, 183, 184)
                                                          and x.billing_frequency = 'MONTHLY' then
                                                         'N'
                                                     else
                                                         'Y'
                                                 end,
                                p_invoice_param_id   => l_inv_param_id,
                                p_user_id            => 0,
                                p_charged_to         => x.pay_acct_fees
                            );
                        end if;

                    end loop;
                elsif x.account_type in ( 'FSA', 'HRA', 'FORM_5500' ) then
                    if x.account_type in ( 'FSA', 'HRA' ) then
                        l_ndt_comprehensive := 'N';
         -- IF X.ACCOUNT_TYPE = 'FSA' THEN
                        for ndt in (
                            select
                                ndt_preference
                            from
                                account_preference
                            where
                                    upper(ndt_preference) = 'COMPREHENSIVE'
                                and acc_id = x.acc_id
                        ) loop
                            if ndt.ndt_preference = 'COMPREHENSIVE' then
                                l_ndt_comprehensive := 'Y';
                            end if;
                        end loop;
        -- END IF;
           /* FOR P IN ( SELECT LISTAGG(plan_type, ',') WITHIN GROUP (ORDER BY acc_id)  plan_list
                         FROM ben_plan_enrollment_setup  WHERE acc_id = x.acc_id )

           FOR P IN  ( SELECT PC_LOOKUPS.GET_meaning(PLAN_TYPE,'FSA_HRA_PRODUCT_MAP') product_type,
                                      LISTAGG(plan_type, ',') WITHIN GROUP (ORDER BY acc_id)  plan_list
                             FROM ben_plan_enrollment_setup
                           WHERE acc_id = x.acc_id
                               and PC_LOOKUPS.GET_meaning(PLAN_TYPE,'FSA_HRA_PRODUCT_MAP') = x.product_type
                       GROUP BY PC_LOOKUPS.GET_meaning(PLAN_TYPE,'FSA_HRA_PRODUCT_MAP')  ) */
          -- Added code by Joshi for #11289.
          -- invoices should be generated only for plans enrolled through online.
                        for p in (
                            select
                                pc_lookups.get_meaning(bp.plan_type, 'FSA_HRA_PRODUCT_MAP') product_type,
                                listagg(bp.plan_type, ',') within group(
                                order by
                                    bp.acc_id
                                )                                                           plan_list
                            from
                                ben_plan_enrollment_setup   bp,
                                online_fsa_hra_staging      os,
                                online_fsa_hra_plan_staging ops
                            where
                                    bp.acc_id = x.acc_id
                                and bp.entrp_id = os.entrp_id
                                and os.batch_number = ops.batch_number
                                and os.enrollment_id = ops.enrollment_id
                                and bp.entrp_id = os.entrp_id
                                and bp.plan_type = ops.plan_type
                                and os.batch_number = x.staging_batch_number
                            group by
                                pc_lookups.get_meaning(bp.plan_type, 'FSA_HRA_PRODUCT_MAP')
                        ) loop
                            l_description := null;
                            if p.plan_list is not null then
                                l_plan_list := p.plan_list;
                                l_fee := pc_plan.get_hra_fsa_fees(p.plan_list, x.entrp_id, 'SETUP_FEE', 'N', x.no_of_eligible);

                                if nvl(l_ndt_comprehensive, 'N') = 'Y' then
                                    l_fee_ndt := pc_plan.get_hra_fsa_fees(p.plan_list, x.entrp_id, 'SETUP_FEE', 'Y', x.no_of_eligible
                                    );
                                end if;

                            end if;

                            select
                                reason_code,
                                reason_name
                            into
                                l_rate_code,
                                l_reason_name
                            from
                                pay_reason
                            where
                                    plan_type = p.product_type
                                and reason_mapping = 1
                                and upper(reason_name) like '%SETUP%';

                            pc_invoice.get_description(
                                p_account_type    => x.account_type,
                                p_acc_id          => x.acc_id,
                                p_source          => x.source,
                                p_ben_plan_id     => x.ben_plan_id,
                                p_ben_plan_number => null,
                                p_plan_type       => l_description
                            );

                            if nvl(l_fee, 0) <> 0 then
                                pc_invoice.insert_rate_plan_detail(
                                    p_rate_plan_id       => l_rate_plan_id,
                                    p_calculation_type   => 'AMOUNT',
                                    p_minimum_range      => null,
                                    p_maximum_range      => null,
                                    p_description        => l_description,
                                    p_rate_code          => l_rate_code,
                                    p_rate_plan_cost     => l_fee,
                                    p_rate_basis         => 'FLAT_FEE',
                                    p_effective_date     => x.plan_start_date, --SYSDATE,
                                    p_effective_end_date => null,--SYSDATE,
                                    p_one_time_flag      => 'Y',
                                    p_invoice_param_id   => l_inv_param_id,
                                    p_user_id            => 0,
                                    p_charged_to         => x.pay_acct_fees
                                );
                            end if;

                            if nvl(l_ndt_comprehensive, 'N') = 'Y' then
                     -- NDT inclusive fee - fees without NDT
                                l_fee_ndt := nvl(l_fee_ndt, 0) - nvl(l_fee, 0);
                                if nvl(l_fee_ndt, 0) > 0 then
                                    pc_invoice.insert_rate_plan_detail(
                                        p_rate_plan_id       => l_rate_plan_id,
                                        p_calculation_type   => 'AMOUNT',
                                        p_minimum_range      => null,
                                        p_maximum_range      => null,
                                        p_description        => null,
                                        p_rate_code          =>
                                                     case
                                                         when p.product_type = 'FSA' then
                                                             269
                                                         else
                                                             270
                                                     end,
                                        p_rate_plan_cost     => l_fee_ndt,
                                        p_rate_basis         => 'FLAT_FEE',
                                        p_effective_date     => x.plan_start_date, --SYSDATE,
                                        p_effective_end_date => null,--SYSDATE,
                                        p_one_time_flag      => 'Y',
                                        p_invoice_param_id   => l_inv_param_id,
                                        p_user_id            => 0,
                                        p_charged_to         => x.pay_acct_fees
                                    );

                                end if;

                            end if;

                        end loop;

                    else
                -- arh.ben_plan_number is used for description formation in pc_invoice.get_description
                        for rp in (
                            select distinct
                                arl.line_list_price,
                                rpd.rate_code,
                                pr.reason_name,
                                arh.ben_plan_number
                            from
                                ar_quote_headers arh,
                                ar_quote_lines   arl,
                                rate_plan_detail rpd,
                                pay_reason       pr,
                                rate_plans       rp
                            where
                                    arh.quote_header_id = x.quote_header_id
                                and arh.entrp_id = x.entrp_id
                                and rp.rate_plan_id = arl.rate_plan_id
                                and arh.quote_header_id = arl.quote_header_id
                                and rp.rate_plan_id = rpd.rate_plan_id
                                and arl.rate_plan_detail_id = rpd.rate_plan_detail_id
                                and rpd.rate_code = pr.reason_code
                                          --AND X.ACCOUNT_TYPE NOT IN ('FORM_5500')
                                and x.account_type in ( 'FORM_5500' )
                                and arl.line_list_price > 0
                        ) loop
                            pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice: inserting rate_plan_detail rp.rate_code '
                            , rp.rate_code);
                            l_fee := rp.line_list_price;
                            l_description := null;
                            pc_invoice.get_description(
                                p_account_type    => x.account_type,
                                p_acc_id          => x.acc_id,
                                p_source          => x.source,
                                p_ben_plan_id     => x.ben_plan_id,
                                p_ben_plan_number => rp.ben_plan_number,
                                p_plan_type       => l_plan_type
                            );

                            if rp.rate_code <> 62 then
                                l_description := 'Health and Welfare Form 5500 - Plan ' || l_plan_type;
                            else
                                l_description := 'Health and Welfare Form 5500 - Plan '
                                                 || l_plan_type
                                                 || '-'
                                                 || ' Final Filing';
                            end if;

                            l_rate_code := 1;   -- now

                            if nvl(l_fee, 0) <> 0 then
                                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice: inserting rate_plan_detail l_rate_plan_id '
                                , l_rate_plan_id
                                                                                                                                              || ' l_fee :='
                                                                                                                                              || l_fee
                                                                                                                                              || ' X.QUOTE_HEADER_ID :='
                                                                                                                                              || x.quote_header_id
                                                                                                                                              || ' l_inv_param_id :='
                                                                                                                                              || l_inv_param_id
                                                                                                                                              )
                                                                                                                                              ;

                                pc_invoice.insert_rate_plan_detail(
                                    p_rate_plan_id       => l_rate_plan_id,
                                    p_calculation_type   => 'AMOUNT',
                                    p_minimum_range      => null,
                                    p_maximum_range      => null,
                                    p_description        => l_description, --l_reason_name,
                                    p_rate_code          => l_rate_code,
                                    p_rate_plan_cost     => l_fee,
                                    p_rate_basis         => 'FLAT_FEE',
                                    p_effective_date     => x.plan_start_date, --SYSDATE,
                                    p_effective_end_date => null,--SYSDATE,
                                    p_one_time_flag      => 'Y',
                                    p_invoice_param_id   => l_inv_param_id,
                                    p_user_id            => 0,
                                    p_charged_to         => x.pay_acct_fees
                                );

                            end if;

                        end loop;
                    end if;
                end if;

    -- populate discount rate line lines
  /*  pc_invoice.insert_discount_rate_lines (
                                          p_batch_number => x.batch_number
                                        , p_entrp_id            => x.entrp_id
                                        , p_quote_header_id     => x.QUOTE_HEADER_ID
                                        , p_rate_plan_id        => l_rate_plan_id
                                        , P_INVOICE_PARAM_ID    => l_inv_param_id
                                        , p_source              => x.source
                                        , p_fee                 => l_fee
                                        ); */
                if
                    x.product_type = 'HRA'
                    and pc_account.is_stacked_account_new(x.entrp_id) = 'Y'
                then
                    null;
                else
                    pc_invoice.insert_discount_rate_lines(
                        p_batch_number     => x.batch_number,
                        p_entrp_id         => x.entrp_id,
                        p_quote_header_id  => x.quote_header_id,
                        p_rate_plan_id     => l_rate_plan_id,
                        p_invoice_param_id => l_inv_param_id,
                        p_source           => x.source,
                        p_fee              => l_fee
                    );
                end if;

      --  HAWAII state rates

                l_state := pc_entrp.get_state(x.entrp_id);
                l_city := pc_entrp.get_city(x.entrp_id);
                if upper(l_state) = 'HI' then
                    l_tax_rate := pc_lookups.get_hawaii_tax_rate(l_city);
                    if nvl(l_tax_rate, 0) <> 0 then
                        pc_invoice.insert_rate_plan_detail(
                            p_rate_plan_id       => l_rate_plan_id,
                            p_calculation_type   => 'AMOUNT',
                            p_minimum_range      => null,
                            p_maximum_range      => null,
                            p_description        => l_description, --CASE WHEN  X.ACCOUNT_TYPE = 'FORM_5500' THEN l_description ELSE  NULL END,
                            p_rate_code          => '85',
                            p_rate_plan_cost     => l_tax_rate,
                            p_rate_basis         => 'ACTIVE',
                            p_effective_date     => x.plan_start_date,
                            p_effective_end_date => null,
                            p_one_time_flag      => 'N',
                            p_invoice_param_id   => l_inv_param_id,
                            p_user_id            => 0,
                            p_charged_to         => x.pay_acct_fees
                        );

                    end if;

                end if;

                pc_log.log_error('pc_invoice_jaggi.Generate_daily_setup_renewal_invoice calling generate_invoice HAWAII loop end: l_state '
                , l_state);
                if x.account_type = 'COBRA' then
                    l_opt_fee_bank_acct_id := null;
                    l_opt_fee_payment_method := null;
                    l_opt_fee_autopay := null;
                    l_opt_fee_payment_term := null;
                    l_payment_method := null;
                    l_payment_term := null;
                    l_bank_acct_id := null;
                    l_auto_pay := null;
                    pc_log.log_error('pc_invoice.Generate_daily_setup_renewal_invoice X.pay_acct_fees ', x.pay_acct_fees
                                                                                                         || ' x.MTH_OPT_FEE_PAID_BY :='
                                                                                                         || x.mth_opt_fee_paid_by);

        -- added by swamy for ticket#11262
                    l_opt_fee_invoice_generated := 'N';
                    if upper(x.pay_acct_fees) <> upper(x.mth_opt_fee_paid_by) then
                        pc_log.log_error('pc_invoice.Generate_daily_setup_renewal_invoice X.pay_acct_fees **1 ', x.pay_acct_fees);
            -- generate optional services invoice first
            -- generate setup/renewal invoice second.
                        for i in (
                            select
                                payment_method,
                                payment_term,
                                autopay,
                                bank_acct_id
                            from
                                invoice_parameters
                            where
                                invoice_param_id = l_inv_param_id
                        ) loop
                            l_payment_method := i.payment_method;
                            l_payment_term := i.payment_term;
                            l_bank_acct_id := i.bank_acct_id;
                            l_auto_pay := i.autopay;
                        end loop;

                        l_start_date := trunc(x.plan_start_date);
                        l_end_date := trunc(x.plan_end_date);

            --  update invoice parameter with option_fee_payment_method
                        pc_log.log_error('pc_invoice.Generate_daily_setup_renewal_invoice X.l_start_date **1 ', l_start_date
                                                                                                                || 'l_end_date ='
                                                                                                                || l_end_date);
                        if x.mth_opt_fee_bank_acct_id is not null then
                -- Added by Swamy for Ticket#12534
                            l_bank_acct_id_opt := null;
                            for bank_acct in (
                                select
                                    bank_acct_id
                                from
                                    bank_accounts
                                where
                                        bank_acct_id = x.mth_opt_fee_bank_acct_id
                                    and status = 'A'
                            ) loop
                                l_bank_acct_id_opt := bank_acct.bank_acct_id;
                            end loop;

                            if nvl(l_bank_acct_id_opt, 0) <> 0 then
                                l_opt_fee_bank_acct_id := x.mth_opt_fee_bank_acct_id;
                                l_opt_fee_payment_method := 'DIRECT_DEPOSIT';
                                l_opt_fee_autopay := 'Y';
                                l_opt_fee_payment_term := 'IMMEDIATE';
                            else
                                l_opt_fee_bank_acct_id := null;
                                l_opt_fee_payment_method := 'ACH_PUSH';
                                l_opt_fee_autopay := 'N';
                                l_opt_fee_payment_term := 'NET15';
                            end if;

                /*l_opt_fee_bank_acct_id := x.mth_opt_fee_bank_acct_id ;
                l_opt_fee_payment_method := 'DIRECT_DEPOSIT' ;
                l_opt_fee_autopay := 'Y';
                l_opt_fee_payment_term := 'IMMEDIATE';*/
                        else
                            l_opt_fee_bank_acct_id := null;
                            l_opt_fee_payment_method := 'ACH_PUSH';
                            l_opt_fee_autopay := 'N';
                            l_opt_fee_payment_term := 'NET15';
                        end if;

                        update invoice_parameters
                        set
                            payment_method = l_opt_fee_payment_method,
                            payment_term = l_opt_fee_payment_term,
                            autopay = l_opt_fee_autopay,
                            bank_acct_id = l_opt_fee_bank_acct_id,
                            invoice_frequency = 'ONCE'
                        where
                            invoice_param_id = l_inv_param_id;

            -- update rate plan detail effective end date for monthlly or annual fee rate codes  to sysdate/l_end_date.
            -- 184 is cobra setup fees.

                        update rate_plan_detail
                        set
                            effective_end_date = trunc(sysdate + 1)
                        where
                            effective_end_date is null
                            and invoice_param_id = l_inv_param_id
                            and rate_plan_id = l_rate_plan_id
                            and rate_code not in ( 86, 266, 54, 55 );

                        update rate_plan_detail
                        set
                            charged_to = upper(x.mth_opt_fee_paid_by)
                        where
                                invoice_param_id = l_inv_param_id
                            and rate_code in ( 86, 266, 54, 55 )
                            and rate_plan_id = l_rate_plan_id;

                        pc_log.log_error('pc_invoice.Generate_daily_setup_renewal_invoice calling generate_invoice l_start_date ', l_start_date
                                                                                                                                 || ' l_end_date :='
                                                                                                                                 || l_end_date
                                                                                                                                 || ' x.entrp_id :='
                                                                                                                                 || x.entrp_id
                                                                                                                                 || 'x.account_type :='
                                                                                                                                 || x.account_type
                                                                                                                                 || 'X.Billing_frequency :='
                                                                                                                                 || x.billing_frequency
                                                                                                                                 || 'l_invoice_batch_number :='
                                                                                                                                 || l_invoice_batch_number
                                                                                                                                 || ' l_inv_param_id :='
                                                                                                                                 || l_inv_param_id
                                                                                                                                 );

                        pc_invoice.generate_invoice(l_start_date, l_end_date, sysdate, x.entrp_id, x.account_type,
                                                    x_error_status, x_error_message, 'ONCE', null, l_invoice_batch_number);

                        l_opt_fee_invoice_generated := 'Y';
            --
                        if nvl(x_error_status, 'S') = 'S' then
                --update rate_plan_detail to remove the effective end date for Setup/Monthly fee.
                            update rate_plan_detail
                            set
                                effective_end_date = null
                            where
                                    invoice_param_id = l_inv_param_id
                                and rate_code not in ( 86, 266, 54, 55 )
                                and rate_plan_id = l_rate_plan_id
                                and effective_end_date = trunc(sysdate + 1);

                            update rate_plan_detail
                            set
                                effective_end_date = x.plan_start_date
                            where
                                    invoice_param_id = l_inv_param_id
                                and rate_code in ( 86, 266, 54, 55 )
                                and rate_plan_id = l_rate_plan_id;

                        end if;

               --  update invoice parameter with Setup/renewal fee payment details.
                        update invoice_parameters
                        set
                            payment_method = l_payment_method,
                            payment_term = l_payment_term,
                            autopay = l_auto_pay,
                            bank_acct_id = l_bank_acct_id,
                            invoice_frequency = x.billing_frequency
                        where
                            invoice_param_id = l_inv_param_id;

                    end if;

       -- ending 11262
                    pc_log.log_error('pc_invoice.Generate_daily_setup_renewal_invoice calling generate_invoic x.billing_frequency ', x.billing_frequency
                    );
                    if x.billing_frequency = 'MONTHLY' then

            -- Added by Joshi for 11294.
                        for ip in (
                            select
                                payment_method,
                                payment_term,
                                autopay,
                                bank_acct_id
                            from
                                invoice_parameters
                            where
                                invoice_param_id = l_inv_param_id
                        ) loop
                            populate_monthly_inv_payment_dtl(
                                p_entrp_id        => x.entrp_id,
                                p_source          => x.source,
                                p_payment_method  => ip.payment_method,
                                p_bank_acct_id    => ip.bank_acct_id,
                                p_charged_to      => x.pay_acct_fees,
                                p_plan_start_date => x.plan_start_date,
                                p_plan_end_date   => x.plan_end_date,
                                p_user_id         => 0
                            );
                        end loop;
         --code ends here Joshi for 11294.

                        for n in (
                            select
                                period_start_date,
                                period_end_date,
                                no_of_period
                            from
                                (
                                    select
                                        add_months(
                                            trunc(x.plan_start_date, 'MM'),
                                            level - 1
                                        )     period_start_date,
                                        last_day(add_months(
                                            trunc(x.plan_start_date, 'MM'),
                                            level - 1
                                        ))    period_end_date,
                                        level no_of_period
                                    from
                                        dual
                                    connect by
                                        level <= ( abs(months_between(sysdate, x.plan_start_date)) + 2 )
                                )
                            where
                                trunc(period_start_date) <= trunc(sysdate)
                        ) loop
                            l_start_date := n.period_start_date;
                            l_end_date := n.period_end_date;
                            pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice cobra start and end dates :', l_start_date
                                                                                                                            || ':'
                                                                                                                            || l_end_date
                                                                                                                            );
                            pc_invoice.generate_invoice(l_start_date, l_end_date, sysdate, x.entrp_id, x.account_type,
                                                        x_error_status, x_error_message, x.billing_frequency, null, l_invoice_batch_number
                                                        );

                            if n.no_of_period = 1 then
               -- rate plan line should be end dated for optional service  after first run to avoid adding them in the consecutive
               -- generation
                                update rate_plan_detail
                                set
                                    effective_end_date = x.plan_start_date
                                where
                                        rate_plan_id = l_rate_plan_id
                                    and one_time_flag = 'Y'
                                    and trunc(effective_date) = x.plan_start_date
                                    and rate_code in ( 86, 266, 54, 55 );

                            end if;

                        end loop;

                    else
                        l_start_date := trunc(x.plan_start_date);
                        l_end_date := trunc(x.plan_end_date);
                        pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice calling generate_invoice **2.1', 'l_start_date :='
                                                                                                                           || l_start_date
                                                                                                                           || 'l_end_date :='
                                                                                                                           || l_end_date
                                                                                                                           || 'x.entrp_id :='
                                                                                                                           || x.entrp_id
                                                                                                                           || ' x.account_type :='
                                                                                                                           || x.account_type
                                                                                                                           || 'X.Billing_frequency :='
                                                                                                                           || x.billing_frequency
                                                                                                                           );

                        pc_invoice.generate_invoice(l_start_date, l_end_date, sysdate, x.entrp_id, x.account_type,
                                                    x_error_status, x_error_message, x.billing_frequency, null, l_invoice_batch_number
                                                    );

                    end if;

                elsif x.account_type in ( 'FSA', 'HRA' ) then
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice calling generate_invoice **2.3', 'l_start_date :=' || x.plan_start_date
                    );
                    pc_invoice.generate_invoice(
                        trunc(x.plan_start_date),
                        trunc(x.plan_end_date),
                        sysdate,
                        x.entrp_id,
                        x.account_type,
                        x_error_status,
                        x_error_message,
                        'SETUP',
                        null,
                        l_invoice_batch_number
                    );
  -- ELSIF X.ACCOUNT_TYPE  = 'COBRA' THEN
     --    PC_INVOICE.generate_invoice(l_start_date,l_end_date,sysdate,x.entrp_id,x.account_type,x_error_status,x_error_message,X.Billing_frequency,null,l_invoice_batch_number);
                else
                    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice calling generate_invoice **2.2', 'l_start_date :=' || x.plan_start_date
                    );
                    pc_invoice.generate_invoice(
                        trunc(x.plan_start_date),
                        trunc(x.plan_end_date),
                        sysdate,
                        x.entrp_id,
                        x.account_type,
                        x_error_status,
                        x_error_message,
                        x.billing_frequency,
                        null,
                        l_invoice_batch_number
                    );

                end if;

    /*
    -- Generate invoice for employer
    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice calling generate_invoice: x.plan_start_date ', x.plan_start_date||'x.plan_end_date :='||x.plan_end_date);
   -- PC_INVOICE.generate_invoice(TRUNC(x.plan_start_date),TRUNC(x.plan_end_date),sysdate,x.entrp_id,x.account_type,x_error_status,x_error_message,'MONTHLY',X.Billing_frequency,l_invoice_batch_number);
      -- Generate invoice for employer
    pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice calling generate_invoice: x.plan_start_date ', x.plan_start_date||'x.plan_end_date :='||x.plan_end_date);
    IF X.ACCOUNT_TYPE in ('FSA','HRA') THEN
         PC_INVOICE.generate_invoice(TRUNC(x.plan_start_date),TRUNC(x.plan_end_date),sysdate,x.entrp_id,x.account_type,x_error_status,x_error_message,'SETUP',null,l_invoice_batch_number);
    ELSIF X.ACCOUNT_TYPE  = 'COBRA' THEN
        PC_INVOICE.generate_invoice(l_start_date,l_end_date,sysdate,x.entrp_id,x.account_type,x_error_status,x_error_message,X.Billing_frequency,null,l_invoice_batch_number);
    ELSE
        PC_INVOICE.generate_invoice(TRUNC(x.plan_start_date),TRUNC(x.plan_end_date),sysdate,x.entrp_id,x.account_type,x_error_status,x_error_message,X.Billing_frequency,null,l_invoice_batch_number);
    END IF;
    */
    --PC_INVOICE.generate_invoice(TRUNC(SYSDATE),TRUNC(SYSDATE),sysdate,x.entrp_id,x.account_type,x_error_status,x_error_message,'MONTHLY',X.Billing_frequency,l_invoice_batch_number);
    --PC_INVOICE.generate_invoice(TRUNC(TRUNC(SYSDATE,'MM')-1,'MM'),LAST_DAY(TRUNC(SYSDATE,'MM')-1),NULL,x.entrp_id,x.account_type,x_error_status,x_error_message,'MONTHLY',X.Billing_frequency,l_invoice_batch_number);
                pc_log.log_error('PC_INVOICE.Generate_daily_setup_renewal_invoice calling generate_invoice: x.plan_start_date ', l_invoice_batch_number || l_invoice_batch_number
                );
                for j in (
                    select
                        invoice_id
                    from
                        ar_invoice
                    where
                            entity_id = x.entrp_id
                        and entity_type = 'EMPLOYER'
                        and trunc(creation_date) = trunc(sysdate)
                        and batch_number = l_invoice_batch_number
                ) loop
                    update daily_enroll_renewal_account_info a
                    set
                        invoice_id = j.invoice_id,
                        error_status = 'S'
                    where
                            a.batch_number = p_batch_number
                        and a.source = 'SETUP'
                        and product_type = x.product_type
                        and invoice_id is null
                        and entrp_id = x.entrp_id
                        and ( x.quote_header_id is null
                              or ( x.quote_header_id is not null
                                   and quote_header_id = x.quote_header_id ) );

                end loop;

   -- Insert monthly maintainence rate line items.
                if x.account_type in ( 'FSA', 'HRA' ) then
       -- For setup/Renewal FSA/HRA invoices , the rate plans end date should be set to plan start date.
       -- so that they these rate lines are included in monthly invoice.
                    update rate_plan_detail
                    set
                        effective_end_date = trunc(x.plan_start_date)
                    where
                            rate_plan_id = l_rate_plan_id
                        and one_time_flag = 'Y'
                        and trunc(effective_end_date) = trunc(x.plan_end_date);

                    pc_invoice.insert_fsa_hra_monthly_rate_lines(
                        p_entrp_id         => x.entrp_id,
                        p_rate_plan_id     => l_rate_plan_id,
                        p_invoice_param_id => l_inv_param_id,
                        p_source           => x.source,
                        p_batch_number     => p_batch_number
                    );

                end if;

            exception
                when erreur then
                    update daily_enroll_renewal_account_info a
                    set
                        error_status = 'E',
                        error_message = x_error_message
                    where
                            a.batch_number = p_batch_number
                        and a.source = 'SETUP'
                        and entrp_id = x.entrp_id;

                when others then
                    x_error_message := substr(sqlerrm, 1, 200);
                    update daily_enroll_renewal_account_info a
                    set
                        error_status = 'E',
                        error_message = x_error_message
                    where
                            a.batch_number = p_batch_number
                        and a.source = 'SETUP'
                        and entrp_id = x.entrp_id;

            end;
        end loop;

        pc_notifications.daily_setup_renewal_invoice_notify(
            p_batch_number => p_batch_number,
            p_source       => 'SETUP'
        );
    end generate_daily_setup_invoice;

    procedure insert_fsa_hra_monthly_rate_lines (
        p_entrp_id         in number,
        p_rate_plan_id     in number,
        p_invoice_param_id in number,
        p_source           in varchar2,
        p_batch_number     in number
    ) is

        l_rate_code                  varchar2(10);
        l_rate_plan_id               number;
        l_plan_type_count            number;
        l_description                varchar2(500);
        l_inv_param_id               number;
        l_rate_cost                  number;
        l_plan_type                  varchar2(100);
        l_plan_start_date            date;
        l_card_allow                 number;
        l_plan_list                  varchar2(4000);
        l_acc_id                     number;
        l_trn_pkg_cnt                number;
        l_fsa_combo_cnt              number;
        l_rate_line_cnt              number;
        l_pppm_discount              number;
        l_pay_acct_fees              varchar2(100);
        l_mth_opt_fee_payment_method varchar2(100);
        l_mth_opt_fee_bank_acct_id   varchar2(100);
        l_monthly_fees_paid_by       varchar2(100);
        l_rate_plan_detail_id        number := 0;
        l_entrp_id                   number;
        l_batch_number               number;
    begin
        l_acc_id := pc_entrp.get_acc_id(p_entrp_id);
        l_pppm_discount := pc_invoice.get_pppm_discount(l_acc_id, p_source);
        l_entrp_id := null;
        l_batch_number := null;

    -- Added by jaggi #11263 
        for x in (
            select
                *
            from
                daily_enroll_renewal_account_info
            where
                    batch_number = p_batch_number
                and entrp_id = p_entrp_id
                and source = p_source
        ) loop
            l_pay_acct_fees := nvl(x.pay_acct_fees, 'EMPLOYER');
            l_mth_opt_fee_payment_method := x.mth_opt_fee_payment_method;
            l_mth_opt_fee_bank_acct_id := x.mth_opt_fee_bank_acct_id;
            l_monthly_fees_paid_by := nvl(x.mth_opt_fee_paid_by, 'EMPLOYER');
            l_batch_number := x.staging_batch_number;
            l_entrp_id := x.entrp_id;
            if l_pay_acct_fees <> l_monthly_fees_paid_by then

            -- Added by Joshi for 12269 . if the bank account is inactive . the payment_methos should be change to ACH_PUSH
                if
                    l_mth_opt_fee_bank_acct_id is not null
                    and l_mth_opt_fee_payment_method = 'ACH'
                then
                    for x in (
                        select
                            status
                        from
                            bank_accounts
                        where
                            bank_acct_id = l_mth_opt_fee_bank_acct_id
                    ) loop
                        if nvl(x.status, 'A') <> 'A' then
                            l_mth_opt_fee_payment_method := 'ACH_PUSH';
                            l_mth_opt_fee_bank_acct_id := null;
                        end if;
                    end loop;
                end if; 
            -- code ends here 12269

         -- update the invoice_frequency to monthly.
                update invoice_parameters
                set
                    invoice_frequency = 'MONTHLY',
                    payment_method = decode(l_mth_opt_fee_payment_method, 'ACH', 'DIRECT_DEPOSIT', l_mth_opt_fee_payment_method),
                    payment_term = decode(l_mth_opt_fee_payment_method, 'ACH', 'IMMEDIATE', 'NET15'),
                    bank_acct_id = l_mth_opt_fee_bank_acct_id,
                    autopay = decode(l_mth_opt_fee_payment_method, 'ACH', 'Y', 'N')
                where
                        invoice_param_id = p_invoice_param_id
                    and invoice_type = 'FEE'
                    and entity_id = p_entrp_id
                    and entity_type = 'EMPLOYER';

            else     
         -- update the invoice_frequency to monthly.
                update invoice_parameters
                set
                    invoice_frequency = 'MONTHLY'
                where
                        invoice_param_id = p_invoice_param_id
                    and invoice_type = 'FEE'
                    and entity_id = p_entrp_id
                    and entity_type = 'EMPLOYER';

            end if;

         -- Added by Joshi for 11294.
            for ip in (
                select
                    payment_method,
                    payment_term,
                    autopay,
                    bank_acct_id
                from
                    invoice_parameters
                where
                    invoice_param_id = p_invoice_param_id
            ) loop
                pc_log.log_error('Insert_Fsa_Hra_Monthly_Rate_Lines l_inv_param_id:  ', p_invoice_param_id);
                pc_log.log_error('Insert_Fsa_Hra_Monthly_Rate_Lines ', 'monthly payment_method: '
                                                                       || ip.payment_method
                                                                       || 'Bank acct id: '
                                                                       || ip.bank_acct_id
                                                                       || 'monthly fee paid by : '
                                                                       || l_monthly_fees_paid_by);

                populate_monthly_inv_payment_dtl(
                    p_entrp_id        => x.entrp_id,
                    p_source          => x.source,
                    p_payment_method  => ip.payment_method,
                    p_bank_acct_id    => ip.bank_acct_id,
                    p_charged_to      => l_monthly_fees_paid_by,
                    p_plan_start_date => x.plan_start_date,
                    p_plan_end_date   => x.plan_end_date,
                    p_user_id         => 0
                );

            end loop;
         --code ends here Joshi for 11294.

        end loop;

        for c in (
            select
                acc_id,
                sum(
                    case
                        when plan_type in('TRN', 'PKG', 'UA1') then
                            1
                        else
                            0
                    end
                ) trn_pkg_cnt,
                sum(
                    case
                        when plan_type in('FSA', 'DCA', 'LPF', 'TRN', 'PKG',
                                          'UA1') then
                            1
                        else
                            0
                    end
                ) fsa_combo_cnt,
                sum(
                    case
                        when plan_type in('FSA', 'DCA', 'LPF') then
                            1
                        else
                            0
                    end
                ) combo_cnt
            from
                ben_plan_enrollment_setup
            where
                acc_id = l_acc_id
            group by
                acc_id
        ) loop
            l_trn_pkg_cnt := c.trn_pkg_cnt;
            l_fsa_combo_cnt := c.fsa_combo_cnt;
            if c.combo_cnt >= 1 then
                l_fsa_combo_cnt := c.fsa_combo_cnt;
            else
                l_fsa_combo_cnt := c.combo_cnt;
            end if;

        end loop;

        for x in (
            select distinct
                regexp_replace(plan_type, '(HRA|HRP|HR4|HR5|ACO)', 'HRA') plan_type
            from
                ben_plan_enrollment_setup
            where
                acc_id = l_acc_id
        ) loop
            l_plan_start_date := null;
            pc_log.log_error('PLAN_TYPE ', x.plan_type);
            if x.plan_type = 'HRA' then
                for p in (
                    select
                        min(plan_start_date) plan_start_date
                    from
                        ben_plan_enrollment_setup
                    where
                            entrp_id = p_entrp_id
                        and plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' )
                ) loop
                    l_plan_start_date := p.plan_start_date;
                end loop;
            else
                for p in (
                    select
                        min(plan_start_date) plan_start_date
                    from
                        ben_plan_enrollment_setup
                    where
                            entrp_id = p_entrp_id
                        and plan_type = x.plan_type
                ) loop
                    l_plan_start_date := p.plan_start_date;
                end loop;
            end if;

            select
                case
                    when x.plan_type = 'FSA' then
                        '33'
                    when x.plan_type = 'DCA' then
                        '35'
                    when x.plan_type = 'LPF' then
                        '39'
                    when x.plan_type = 'TRN' then
                        '37'
                    when x.plan_type = 'PKG' then
                        '38'
                    when x.plan_type = 'UA1' then
                        '40'
                    when x.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) then
                        '34'
                end rate_code
            into l_rate_code
            from
                dual;

		-- call function to get the price.
		-- call function to get the price.
            if l_pppm_discount > 0 then
                l_rate_cost := l_pppm_discount;
            else
                if x.plan_type in ( 'HRA', 'HRP', 'HR5', 'HR4', 'ACO' ) then
                    for p in (
                        select
                            batch_number,
                            entity_id,
                            (
                                case
                                    when comprehensive > 0
                                         and lphra > 0 then
                                        'COMP_LPHRA'
                                    when basic > 0
                                         and lphra > 0 then
                                        'BASIC_LPHRA'
                                    when basic > 0
                                         and lphra = 0 then
                                        'BASIC'
                                    when comprehensive > 0
                                         and lphra = 0 then
                                        'COMPREHENSIVE'
                                    else
                                        'LPHRA'
                                end
                            ) hra_plan_type
                        from
                            (
                                select
                                    batch_number,
                                    entity_id,
                                    plan_type
                                from
                                    eligibile_expenses_staging
                            ) pivot (
                                count(distinct plan_type)
                                for plan_type
                                in ( 'COMPREHENSIVE' comprehensive, 'LPHRA' lphra, 'BASIC' basic )
                            )
                        where
                                batch_number = l_batch_number
                            and entity_id = l_entrp_id
                    ) loop
                        l_rate_cost := pc_lookups.get_fsa_hra_monthly_fee(nvl(p.hra_plan_type, 'BASIC'));
                    end loop;

                else
                    l_rate_cost := pc_lookups.get_fsa_hra_monthly_fee(x.plan_type);
                end if;
            end if;

            pc_log.log_error('l_rate_cost ', l_rate_cost);
            pc_log.log_error('L_RATE_CODE ', l_rate_code);
            for y in (
                select
                    column_value rate_basis
                from
                    table ( cast(str2tbl('ACTIVE,RUNOUT') as varchar2_4000_tbl) )
                where
                    column_value is not null
            ) loop
                l_rate_plan_detail_id := 0;
                for k in (
                    select
                        nvl(rate_plan_detail_id, 0) rate_plan_detail_id
                    from
                        rate_plan_detail
                    where
                            rate_plan_id = p_rate_plan_id
                        and invoice_param_id = p_invoice_param_id
                        and rate_code = l_rate_code
                        and rate_basis = y.rate_basis
                        and effective_end_date is null
                ) loop
                    l_rate_plan_detail_id := k.rate_plan_detail_id;
                end loop;

                if
                    nvl(l_rate_cost, 0) > 0
                    and l_rate_plan_detail_id = 0
                then
                    pc_invoice.insert_rate_plan_detail(
                        p_rate_plan_id       => p_rate_plan_id,
                        p_calculation_type   => 'AMOUNT',
                        p_minimum_range      => null,
                        p_maximum_range      => null,
                        p_description        => null,
                        p_rate_code          => l_rate_code,
                        p_rate_plan_cost     => l_rate_cost,
                        p_rate_basis         => y.rate_basis,
                        p_effective_date     => nvl(l_plan_start_date, sysdate),
                        p_effective_end_date => null,
                        p_one_time_flag      => 'N',
                        p_invoice_param_id   => p_invoice_param_id,
                        p_user_id            => 0,
                        p_charged_to         => l_monthly_fees_paid_by
                    );
                else
                    if nvl(l_rate_cost, 0) > 0 then   -- added by Joshi for 12469.
                        update rate_plan_detail
                        set
                            rate_plan_cost = l_rate_cost,
                            charged_to = l_monthly_fees_paid_by --Added by Joshi for 11263
                        where
                                rate_plan_detail_id = l_rate_plan_detail_id
                            and invoice_param_id = p_invoice_param_id
                            and rate_code = l_rate_code
                            and rate_basis = y.rate_basis
                            and effective_end_date is null;

                    else
                        update rate_plan_detail
                        set
                            charged_to = l_monthly_fees_paid_by --Added by Joshi for 11263
                        where
                                rate_plan_detail_id = l_rate_plan_detail_id
                            and invoice_param_id = p_invoice_param_id
                            and rate_code = l_rate_code
                            and rate_basis = y.rate_basis
                            and effective_end_date is null;

                    end if;
                end if;

            end loop;

        end loop;

        if l_fsa_combo_cnt >= 2 then
            for y in (
                select
                    column_value rate_basis
                from
                    table ( cast(str2tbl('ACTIVE,RUNOUT') as varchar2_4000_tbl) )
                where
                    column_value is not null
            ) loop
            -- call function to get the price.
                if l_pppm_discount > 0 then
                    l_rate_cost := l_pppm_discount;
                else
                    l_rate_cost := pc_lookups.get_fsa_hra_monthly_fee('FSA_COMBO');
                end if;

                l_rate_code := 31;
                l_rate_plan_detail_id := 0;
                for k in (
                    select
                        nvl(rate_plan_detail_id, 0) rate_plan_detail_id
                    from
                        rate_plan_detail
                    where
                            rate_plan_id = p_rate_plan_id
                        and invoice_param_id = p_invoice_param_id
                        and rate_code = l_rate_code
                        and rate_basis = y.rate_basis
                        and effective_end_date is null
                ) loop
                    l_rate_plan_detail_id := k.rate_plan_detail_id;
                end loop;

                if l_rate_plan_detail_id = 0 then
                    pc_invoice.insert_rate_plan_detail(
                        p_rate_plan_id       => p_rate_plan_id,
                        p_calculation_type   => 'AMOUNT',
                        p_minimum_range      => null,
                        p_maximum_range      => null,
                        p_description        => null,
                        p_rate_code          => l_rate_code,
                        p_rate_plan_cost     => l_rate_cost,
                        p_rate_basis         => y.rate_basis,
                        p_effective_date     => nvl(l_plan_start_date, sysdate),
                        p_effective_end_date => null, --SYSDATE,
                        p_one_time_flag      => 'N',
                        p_invoice_param_id   => p_invoice_param_id,
                        p_user_id            => 0,
                        p_charged_to         => l_monthly_fees_paid_by
                    );
                else
                    update rate_plan_detail
                    set
                        rate_plan_cost = l_rate_cost,
                        charged_to = l_monthly_fees_paid_by --Added by Joshi for 11263
                    where
                            rate_plan_detail_id = l_rate_plan_detail_id
                        and invoice_param_id = p_invoice_param_id
                        and rate_code = l_rate_code
                        and rate_basis = y.rate_basis
                        and effective_end_date is null;

                end if;

            end loop;
        end if;

        if l_trn_pkg_cnt >= 2 then
            for y in (
                select
                    column_value rate_basis
                from
                    table ( cast(str2tbl('ACTIVE,RUNOUT') as varchar2_4000_tbl) )
                where
                    column_value is not null
            ) loop
             -- call function to get the price.
                if l_pppm_discount > 0 then
                    l_rate_cost := l_pppm_discount;
                else
                    l_rate_cost := pc_lookups.get_fsa_hra_monthly_fee('TRN_PKG');
                end if;

                l_rate_code := 32;
                l_rate_plan_detail_id := 0;
                for k in (
                    select
                        nvl(rate_plan_detail_id, 0) rate_plan_detail_id
                    from
                        rate_plan_detail
                    where
                            rate_plan_id = p_rate_plan_id
                        and invoice_param_id = p_invoice_param_id
                        and rate_code = l_rate_code
                        and rate_basis = y.rate_basis
                        and effective_end_date is null
                ) loop
                    l_rate_plan_detail_id := k.rate_plan_detail_id;
                end loop;

                if l_rate_plan_detail_id = 0 then
                    pc_invoice.insert_rate_plan_detail(
                        p_rate_plan_id       => p_rate_plan_id,
                        p_calculation_type   => 'AMOUNT',
                        p_minimum_range      => null,
                        p_maximum_range      => null,
                        p_description        => null,
                        p_rate_code          => l_rate_code,
                        p_rate_plan_cost     => l_rate_cost,
                        p_rate_basis         => y.rate_basis,
                        p_effective_date     => nvl(l_plan_start_date, sysdate),
                        p_effective_end_date => null,
                        p_one_time_flag      => 'N',
                        p_invoice_param_id   => p_invoice_param_id,
                        p_user_id            => 0,
                        p_charged_to         => l_monthly_fees_paid_by
                    );
                else
                    update rate_plan_detail
                    set
                        rate_plan_cost = l_rate_cost,
                        charged_to = l_monthly_fees_paid_by --Added by Joshi for 11263
                    where
                            rate_plan_detail_id = l_rate_plan_detail_id
                        and invoice_param_id = p_invoice_param_id
                        and rate_code = l_rate_code
                        and rate_basis = y.rate_basis
                        and effective_end_date is null;

                end if;

            end loop;
        end if;

--   add rate plan detail for Card issuance, Debit atm/fee lost card replacement
--   add rate plan detail for Card issuance, Debit atm/fee lost card replacement
        l_card_allow := pc_entrp.card_allowed(p_entrp_id);
        if l_card_allow = 0 then
            for c in (
                select
                    *
                from
                    pay_reason
                where
                    reason_code in ( 16, 4 )
            ) loop
                if c.reason_code = 16 then
                    l_plan_type := 'CARD_ISSUE';
                else
                    l_plan_type := 'CARD_LOST';
                end if;

                l_rate_cost := pc_lookups.get_fsa_hra_monthly_fee(l_plan_type);
                l_rate_plan_detail_id := 0;
                for k in (
                    select
                        nvl(rate_plan_detail_id, 0) rate_plan_detail_id
                    from
                        rate_plan_detail
                    where
                            rate_plan_id = p_rate_plan_id
                        and invoice_param_id = p_invoice_param_id
                        and rate_code = c.reason_code
                        and effective_end_date is null
                ) loop
                    l_rate_plan_detail_id := k.rate_plan_detail_id;
                end loop;

                if l_rate_plan_detail_id = 0 then
                    pc_invoice.insert_rate_plan_detail(
                        p_rate_plan_id       => p_rate_plan_id,
                        p_calculation_type   => 'AMOUNT',
                        p_minimum_range      => null,
                        p_maximum_range      => null,
                        p_description        => null,
                        p_rate_code          => c.reason_code,
                        p_rate_plan_cost     => l_rate_cost,
                        p_rate_basis         => 'CARD',
                        p_effective_date     => nvl(l_plan_start_date, sysdate),
                        p_effective_end_date => null, --SYSDATE,
                        p_one_time_flag      => 'N',
                        p_invoice_param_id   => p_invoice_param_id,
                        p_user_id            => 0,
                        p_charged_to         => l_monthly_fees_paid_by
                    );
                else
                    update rate_plan_detail
                    set
                        rate_plan_cost = l_rate_cost,
                        charged_to = l_monthly_fees_paid_by --Added by Joshi for 11263
                    where
                            rate_plan_detail_id = l_rate_plan_detail_id
                        and invoice_param_id = p_invoice_param_id
                        and rate_code = c.reason_code
                        and rate_basis = 'CARD'
                        and effective_end_date is null;

                end if;

            end loop;
        end if;

    exception
        when others then
            pc_log.log_error(' Error in INSERT_FSA_HRA_MONTHLY_RATE_LINES ',
                             substr(sqlerrm, 1, 200));
    end insert_fsa_hra_monthly_rate_lines;

    procedure get_description (
        p_account_type    in varchar2,
        p_acc_id          in number,
        p_source          in varchar2,
        p_ben_plan_id     in number,
        p_ben_plan_number in varchar2,
        p_plan_type       out varchar2
    ) is
        l_ben_plan_id number := p_ben_plan_id;
        l_plan_type   varchar2(100);
        l_plan_number varchar2(100);
    begin
        if p_source = 'SETUP' then
            for k in (
                select
                    ben_plan_id
                from
                    ben_plan_enrollment_setup
                where
                    acc_id = p_acc_id
            ) loop
                l_ben_plan_id := k.ben_plan_id;
            end loop;
        end if;

        if p_account_type = 'FORM_5500' then
            l_plan_type := p_ben_plan_number;
        elsif p_account_type = 'COBRA' then
            l_plan_type := 'COBRA';
        elsif p_account_type in ( 'ERISA_WRAP', 'POP' ) then
            for m in (
                select
                    decode(p_account_type, 'ERISA_WRAP', erissa_erap_doc_type, plan_type) as plan_type,
                    ben_plan_number
                from
                    ben_plan_enrollment_setup
                where
                    ben_plan_id = l_ben_plan_id
            ) loop
                if upper(m.plan_type) = 'R' then
                    l_plan_type := 'Erisa Wrap';
                elsif upper(m.plan_type) = 'E' then
                    l_plan_type := 'EVERGREEN Erisa';
                elsif upper(m.plan_type) in ( 'COMP_POP', 'COMP_POP_RENEW' ) then
                    l_plan_type := 'Cafeteria';
                elsif upper(m.plan_type) in ( 'BASIC_POP', 'BASIC_POP_RENEW' ) then
                    l_plan_type := 'POP';
                end if;
            end loop;
        end if;

        p_plan_type := l_plan_type;
    end get_description;

    function get_pppm_discount (
        p_acc_id in number,
        p_source in varchar2
    ) return number is
        l_discount number := 0;
    begin
        for x in (
            select
                pppm_fee
            from
                employer_discount
            where
                    acc_id = p_acc_id
                and discount_type = p_source
                -- added by jaggi #11291
                and discount_rec_no = (
                    select
                        max(discount_rec_no)
                    from
                        employer_discount edi
                    where
                            edi.acc_id = employer_discount.acc_id
                        and edi.discount_type = employer_discount.discount_type
                        and ( discount_exp_date is null
                              or discount_exp_date > sysdate )
                )
        ) loop
            l_discount := nvl(x.pppm_fee, 0);
        end loop;

        return l_discount;
    end get_pppm_discount;

-- Added by Joshi for showing charged_to in the SAM approve invoice sceen(#11366)
    function get_charged_to (
        p_invoice_id in number
    ) return varchar2 is
        l_charged_to     varchar2(100) := null;
        l_invoice_reason varchar2(100) := null;
    begin
        for i in (
            select
                invoice_reason
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
            l_invoice_reason := i.invoice_reason;
        end loop;

        if l_invoice_reason <> 'FEE' then
            l_charged_to := 'EMPLOYER';
        else
            for ar in (
                select
                    charged_to
                from
                    ar_invoice
                where
                    invoice_id = p_invoice_id
            ) loop
                l_charged_to := ar.charged_to;
            end loop;

            if l_charged_to is null then
                for x in (
                    select
                        pay_acct_fees
                    from
                        daily_enroll_renewal_account_info
                    where
                        invoice_id = p_invoice_id
                ) loop
                    l_charged_to := x.pay_acct_fees;
                end loop;

            end if;

            if l_charged_to is null then
                for y in (
                    select distinct
                        r.charged_to charged_to
                    from
                        ar_invoice       a,
                        ar_invoice_lines arl,
                        rate_plan_detail r
                    where
                            a.invoice_id = p_invoice_id
                        and a.invoice_id = arl.invoice_id
                        and a.rate_plan_id = r.rate_plan_id
                        and r.rate_code = arl.rate_code
                        and trunc(r.effective_date) <= a.end_date
                   -- AND ( R.EFFECTIVE_END_DATE IS NULL  OR R.EFFECTIVE_END_DATE BETWEEN A.START_DATE AND A.END_DATE)
                        and ( r.effective_end_date is null
                              or r.effective_end_date >= a.end_date )
                ) loop
                    if y.charged_to is not null then
                        l_charged_to := y.charged_to;
                    end if;
                end loop;
            end if;

            if l_charged_to is null then  -- added by jaggi #11484
                l_charged_to := 'EMPLOYER';
            end if;
        end if;

        return ( l_charged_to );
    end;

-- Added by Jaggi #11294
    procedure populate_monthly_inv_payment_dtl (
        p_entrp_id        in number,
        p_source          in varchar2,
        p_payment_method  in varchar2,
        p_bank_acct_id    in varchar2,
        p_charged_to      in varchar2,
        p_plan_start_date in date,
        p_plan_end_date   in date,
        p_user_id         number
    ) is
        l_payment_method varchar2(50);
        l_bank_acct_id   number;
    begin

    -- Added by Joshi for 12269 . if the bank account is inactive . the payment_methos should be change to ACH_PUSH
        l_payment_method := p_payment_method;
        l_bank_acct_id := p_bank_acct_id;
        if
            p_bank_acct_id is not null
            and p_payment_method = 'DIRECT_DEPOSIT'
        then
            for x in (
                select
                    status
                from
                    bank_accounts
                where
                    bank_acct_id = p_bank_acct_id
            ) loop
                if nvl(x.status, 'A') <> 'A' then
                    l_payment_method := 'ACH_PUSH';
                    l_bank_acct_id := null;
                end if;
            end loop;
        end if; 
    -- code ends here 12269

        insert into monthly_invoice_payment_detail (
            entrp_id,
            source,
            payment_method,
            bank_acct_id,
            charged_to,
            plan_start_date,
            plan_end_date,
            created_by,
            creation_date -- added by joshi for 12091
            ,
            last_updated_by,
            last_update_date,
            status -- added by joshi for 12091
            ,
            monthly_payment_seq_no
        )
            select
                p_entrp_id,
                p_source,
                l_payment_method,
                l_bank_acct_id,
                p_charged_to,
                p_plan_start_date,
                p_plan_end_date,
                p_user_id,
                sysdate,
                0,
                sysdate,
                'A',
                monthly_payment_seq_no.nextval
            from
                dual;

    end populate_monthly_inv_payment_dtl;

    procedure post_cc_refund (
        p_invoice_id    in number,
        p_refund_amount in number,
        p_note          in varchar2,
        p_user_id       in number,
        x_error_message out varchar2,
        x_error_status  out varchar2
    ) is
        l_claim_id number;
    begin
        pc_log.log_error('POST_CC_REFUND', 'P_INVOICE_ID' || p_invoice_id);
        x_error_status := 'S';
        l_claim_id := doc_seq.nextval;
        insert into claimn (
            claim_id,
            pers_id,
            pers_patient,
            claim_code,
            prov_name,
            claim_date_start,
            claim_date_end,
            claim_date,
            service_status,
            claim_amount,
            claim_paid,
            claim_pending,
            claim_status,
            approved_amount,
            note,
            pay_reason,
            vendor_id,
            bank_acct_id,
            service_type,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by
        )
            select
                l_claim_id,
                x.entity_id,
                x.entity_id,
                x.invoice_id   --'PREMIUM-INV-'||X.INVOICE_ID
                ,
                x.billing_name,
                x.start_date,
                x.end_date,
                sysdate,
                3,
                p_refund_amount,
                0,
                p_refund_amount,
                'PAID',
                p_refund_amount,
                p_note --'refunded 680.19       (666.85 premium + 13.34 admin fee for Oct 2022)      we did not refund the 20.41 cc fee and this needs to continue to show paid and appear on the fee register despite the refund'
                ,
                290--131
                ,
                null,
                null,
                'COBRA',
                sysdate,
                p_user_id,
                sysdate,
                p_user_id
            from
                ar_invoice x
            where
                invoice_id = p_invoice_id;

        for x in (
            select
                sum(
                    case
                        when i.rate_code in('91', '93') then
                            i.total_line_amount
                        else
                            0
                    end
                ) p,
                sum(
                    case
                        when i.rate_code in('92') then
                            i.total_line_amount
                        else
                            0
                    end
                ) f
            from
                ar_invoice_lines i
            where
                i.rate_code in ( '91', '92', '93' )
                and i.invoice_id = p_invoice_id
        ) loop
            if x.p > 0 then
                insert into payment (
                    change_num,
                    claimn_id,
                    pay_date,
                    amount,
                    reason_code,
                    pay_num,
                    note,
                    acc_id,
                    paid_date,
                    reason_mode
                )
                    select
                        change_seq.nextval,
                        claim_id,
                        claim_date_start,
                        x.p,
                        pay_reason,
                        claim_id,
                        p_note,
                        ac.acc_id,
                        sysdate,
                        'P'
                    from
                        claimn  a,
                        account ac
                    where
                            a.claim_code = to_char(p_invoice_id)
                        and a.pers_id = ac.pers_id
                     --AND A.PAY_REASON IS NOT NULL
                        and not exists (
                            select
                                1
                            from
                                payment
                            where
                                    claimn_id = a.claim_id
                                and reason_mode = 'P'
                        );

            end if;

            if x.f > 0 then
                insert into payment (
                    change_num,
                    claimn_id,
                    pay_date,
                    amount,
                    reason_code,
                    pay_num,
                    note,
                    acc_id,
                    paid_date,
                    reason_mode
                )
                    select
                        change_seq.nextval,
                        claim_id,
                        claim_date_start,
                        x.f,
                        pay_reason,
                        claim_id,
                        p_note,
                        ac.acc_id,
                        sysdate,
                        'FP'
                    from
                        claimn  a,
                        account ac
                    where
                            a.claim_code = to_char(p_invoice_id)
                        and a.pers_id = ac.pers_id
                     --AND A.PAY_REASON IS NOT NULL
                        and not exists (
                            select
                                1
                            from
                                payment
                            where
                                    claimn_id = a.claim_id
                                and reason_mode = 'FP'
                        );

            end if;

        end loop;

        update ar_invoice
        set
            status = 'REFUNDED',
            last_update_date = sysdate,
            last_updated_by = 0
        where
            invoice_id = p_invoice_id;

        update ar_invoice_lines
        set
            status = 'REFUNDED',
            last_update_date = sysdate,
            last_updated_by = 0
        where
            invoice_id = p_invoice_id;

        pc_log.log_error('POST_CC_REFUND', 'x_error_message' || x_error_message);
    exception
        when others then
            x_error_status := 'E';
            x_error_message := sqlerrm;
            raise;
    end post_cc_refund;

-- Added by Joshi for #11801
    function is_monthly_invoice (
        p_invoice_id in number
    ) return varchar2 is
        ls_return varchar2(1) := 'N';
    begin
        for x in (
            select
                count(*) cnt
            from
                ar_invoice       ar,
                ar_invoice_lines arl
            where
                    ar.invoice_id = arl.invoice_id
                and ar.invoice_id = p_invoice_id
                and arl.rate_code in ( 31, 32, 33, 34, 35,
                                       37, 38, 39, 40, 184,
                                       182 )
        ) loop
            if x.cnt > 0 then
                ls_return := 'Y';
            else
                ls_return := 'N';
            end if;
        end loop;

        return ls_return;
    end is_monthly_invoice;

-- Added by Joshi for 11998.
    function get_cobra_monthly_admin_fee return number is
        l_cobra_monthly_admin_fee number := 0;
    begin
        for x in (
            select
                rpd.rate_plan_cost cobra_admin_fee
            from
                rate_plans       rp,
                rate_plan_detail rpd
            where
                    rp.rate_plan_id = rpd.rate_plan_id
                and rp.rate_plan_name = 'COBRA_STANDARD_FEES'
                and rp.account_type = 'COBRA'
                and rpd.rate_code = 183
        ) loop
            l_cobra_monthly_admin_fee := x.cobra_admin_fee;
        end loop;

        return l_cobra_monthly_admin_fee;
    end get_cobra_monthly_admin_fee;

-- Added by Joshi for 12255 
    function get_invoice_cc_detail (
        p_invoice_id number
    ) return invoice_creditcard_info_t
        pipelined
        deterministic
    is
        l_record invoice_creditcard_info_rec;
    begin
        for x in (
            select
                invoice_id,
                invoice_amount,
                invoice_amount * g_credit_card_fee credit_card_fee
            from
                ar_invoice
            where
                invoice_id = p_invoice_id
        ) loop
            l_record.invoice_id := x.invoice_id;
            l_record.invoice_amount := x.invoice_amount;
            l_record.credit_card_fee := round(x.credit_card_fee, 2);
            l_record.total_pay_amount := round((x.invoice_amount + x.credit_card_fee), 2);

            pipe row ( l_record );
        end loop;
    end get_invoice_cc_detail;

-- Added by Joshi for 12255 
    procedure post_cc_fee_invoice (
        p_batch_number  number,
        p_invoice_id    number,
        p_user_id       number,
        x_error_status  out varchar2,
        x_error_message out varchar2
    ) is
        not_able_to_post_excep exception;
        l_batch_number  number;
        l_error_status  varchar2(1);
        l_error_message varchar2(4000);
    begin
        x_error_status := 'S';
        pc_log.log_error('post_cc_fee_invoice', 'x.P_BATCH_NUMBER: ' || p_batch_number);
        pc_log.log_error('post_cc_fee_invoice', 'P_INVOICE_ID: ' || p_invoice_id);      
 -- pc_log.log_error('post_cc_fee_invoice', 'x.invoice_id: ' || x.invoice_id);      

        insert into credit_card_invoice_payments (
            invoice_payment_id,
            batch_number,
            invoice_id,
            session_id,
            cust_first_name,
            cust_last_name,
            billing_address1,
            billing_address2,
            billing_city,
            billing_state,
            billing_zip,
            transaction_id,
            transaction_response_code,
            auth_code,
            msg_code,
            transaction_description,
            account_type,
            account_number,
            transaction_time,
            creation_date
        )
            select
                invoice_payment_seq.nextval,
                batch_number,
                invoice_id,
                session_id,
                cust_first_name,
                cust_last_name,
                billing_address1,
                billing_address2,
                billing_city,
                billing_state,
                billing_zip,
                transaction_id,
                transaction_response_code,
                auth_code,
                msg_code,
                transaction_description,
                account_type,
                account_number,
                transaction_time,
                sysdate
            from
                creditcard_response_detail,
                json_table ( creditcard_response_detail.document_data, '$[*]'
                        columns (
                            invoice_id varchar2 ( 255 ) path '$.transactResponse.invoice_id',
                            session_id varchar2 ( 255 ) path '$.transactResponse.session_id',
                            cust_first_name varchar2 ( 255 ) path '$.transactResponse.cust_first_name',
                            cust_last_name varchar2 ( 255 ) path '$.transactResponse.cust_last_name',
                            billing_address1 varchar2 ( 255 ) path '$.transactResponse.billing_address1',
                            billing_address2 varchar2 ( 255 ) path '$.transactResponse.billing_address2',
                            billing_city varchar2 ( 255 ) path '$.transactResponse.billing_city',
                            billing_state varchar2 ( 255 ) path '$.transactResponse.billing_state',
                            billing_zip varchar2 ( 255 ) path '$.transactResponse.billing_zip',
                            transaction_id varchar2 ( 255 ) path '$.transactResponse.transaction_id',
                            transaction_response_code varchar2 ( 255 ) path '$.transactResponse.transaction_response_code',
                            auth_code varchar2 ( 255 ) path '$.transactResponse.auth_code',
                            msg_code varchar2 ( 255 ) path '$.transactResponse.ref_id',
                            account_type varchar2 ( 255 ) path '$.transactResponse.account_type',
                            account_number varchar2 ( 255 ) path '$.transactResponse.account_number',
                            transaction_time varchar2 ( 255 ) path '$.transactResponse.dateTime',
                            transaction_description varchar2 ( 255 ) path '$.transactResponse.transaction_description'
                        )
                    )
                as jbios
            where
                    batch_number = p_batch_number
                and nvl(processed_flag, 'N') = 'N'
                and document_type = 'FEE_CC_PAYMENT';

        update creditcard_response_detail ed
        set
            processed_flag = 'Y'
        where
                batch_number = p_batch_number
            and exists (
                select
                    *
                from
                    credit_card_invoice_payments cc
                where
                    cc.batch_number = ed.batch_number
            );

        for x in (
            select
                ar.entity_id,
                cc.invoice_id,
                cc.transaction_id,
                ar.acc_num,
                ar.invoice_amount,
                ar.charged_to,
                round((ar.invoice_amount * g_credit_card_fee), 2) credit_card_fee,
                ip.invoice_param_id,
                ip.rate_plan_id,
                ar.start_date,
                ar.end_date,
                pc_account.get_account_type(ar.acc_id)            account_type
            from
                credit_card_invoice_payments cc,
                ar_invoice                   ar,
                invoice_parameters           ip
            where
                    cc.invoice_id = ar.invoice_id
                and ar.entity_type = 'EMPLOYER'
                and cc.batch_number = p_batch_number
                and ar.entity_id = ip.entity_id
                and ar.entity_type = ip.entity_type
                and ip.invoice_type = 'FEE'
                and ip.status = 'A'
                and cc.invoice_id = p_invoice_id
        ) loop
            pc_log.log_error('post_cc_fee_invoice', 'x.invoice_id: ' || x.invoice_id);
            update ar_invoice
            set
                payment_method = 'CREDIT_CARD',
                invoice_term = 'NET15',
                bank_acct_id = null,
                auto_pay = 'N'
            where
                invoice_id = x.invoice_id;

            pc_invoice.post_invoices(
                p_invoice_id     => x.invoice_id,
                p_check_number   => 'CC' || x.transaction_id,
                p_check_amount   => x.invoice_amount,
                p_payment_method => 2  --- Credit card
                ,
                p_check_date     => sysdate,
                p_user_id        => p_user_id,
                p_paid_by        => x.charged_to
            );

            for i in (
                select
                    status
                from
                    ar_invoice
                where
                    invoice_id = x.invoice_id
            ) loop
                if i.status <> 'POSTED' then
                    update creditcard_response_detail
                    set
                        process_message = nvl(process_message, ' ')
                                          || 'Not able to POST invoice:  '
                                          || x.invoice_id
                    where
                        batch_number = p_batch_number;

                    raise not_able_to_post_excep;
                end if;
            end loop;

                -- Generate invoice for Credit Card fee.
            pc_invoice.insert_rate_plan_detail(
                p_rate_plan_id       => x.rate_plan_id,
                p_calculation_type   => 'AMOUNT',
                p_minimum_range      => null,
                p_maximum_range      => null,
                p_description        => null,
                p_rate_code          => 260,
                p_rate_plan_cost     => x.credit_card_fee,
                p_rate_basis         => 'FLAT_FEE',
                p_effective_date     => x.start_date, --SYSDATE,
                p_effective_end_date => null, --SYSDATE,
                p_one_time_flag      => 'Y',
                p_invoice_param_id   => x.invoice_param_id,
                p_user_id            => 0,
                p_charged_to         => x.charged_to   -- added by swamy for ticket#11119
            );

            pc_invoice.generate_invoice(x.start_date, x.end_date, sysdate, x.entity_id, x.account_type,
                                        l_error_status, l_error_message, 'ONCE', null, l_batch_number);

            pc_log.log_error('post_cc_fee_invoice', 'Credit card fee l_batch_number ID : ' || l_batch_number);
            if l_batch_number is not null then
                for ar in (
                    select
                        invoice_id
                    from
                        ar_invoice
                    where
                        batch_number = l_batch_number
                ) loop
                    update ar_invoice
                    set
                        payment_method = 'CREDIT_CARD',
                        invoice_term = 'NET15',
                        bank_acct_id = null,
                        auto_pay = 'N'
                    where
                        invoice_id = ar.invoice_id;

                    pc_invoice.approve_invoice(ar.invoice_id, 0);
                    pc_invoice.post_invoices(
                        p_invoice_id     => ar.invoice_id,
                        p_check_number   => 'CC' || x.transaction_id,
                        p_check_amount   => x.credit_card_fee,
                        p_payment_method => 2  --- Credit card
                        ,
                        p_check_date     => sysdate,
                        p_user_id        => p_user_id,
                        p_paid_by        => x.charged_to
                    );

                    update ar_invoice
                    set
                        cc_fee_invoice_id = ar.invoice_id
                    where
                        invoice_id = x.invoice_id;

                end loop;
            end if;

        end loop;

    exception
        when not_able_to_post_excep then
            x_error_status := 'E';
            pc_log.log_error('POST_CC_FEE_INVOICE', 'error_message: ' || sqlerrm);
        when others then
            x_error_status := 'E';
            pc_log.log_error('POST_CC_FEE_INVOICE', 'error_message: ' || sqlerrm);
    end post_cc_fee_invoice;

    function get_cc_payment_detail (
        p_invoice_id in number
    ) return sys_refcursor is
        l_cc_fee_invoice_amt number;
        thecursor            sys_refcursor;
    begin
        for x in (
            select
                invoice_amount
            from
                ar_invoice
            where
                invoice_id = (
                    select
                        cc_fee_invoice_id
                    from
                        ar_invoice
                    where
                        invoice_id = p_invoice_id
                )
        ) loop
            l_cc_fee_invoice_amt := nvl(x.invoice_amount, 0);
        end loop;

        open thecursor for select
                                                ar.invoice_id,
                                                ar.invoice_posted_date,
                                                'Credit Card'                            payment_method,
                                                cc.account_type,
                                                cc.account_number,
                                                ar.invoice_amount                        original_payment_amount,
                                                l_cc_fee_invoice_amt                     credit_card_fee,
                                                ar.invoice_amount + l_cc_fee_invoice_amt total_amount,
                                                cc.transaction_id,
                                                cc.creation_date                         transaction_date,
                                                ar.start_date                            coverage_start_date,
                                                ar.end_date                              coverage_end_date,
                                                ar.creation_date                         payment_processing_date,
                                                pc_entrp.get_entrp_name(ar.entity_id)    employer_name,
                                                ac.acc_num
                                            from
                                                ar_invoice                   ar,
                                                credit_card_invoice_payments cc,
                                                account                      ac
                          where
                                  ar.invoice_id = p_invoice_id
                              and ar.status = 'POSTED'
                              and ar.invoice_id = cc.invoice_id
                              and ar.entity_type = 'EMPLOYER'
                              and ar.acc_id = ac.acc_id;

        return thecursor;
    end get_cc_payment_detail;

    function get_original_invoice_id (
        p_cc_fee_invoice_id number
    ) return number is
        l_orig_invoice_id number;
    begin
        for x in (
            select
                invoice_id
            from
                ar_invoice
            where
                cc_fee_invoice_id = p_cc_fee_invoice_id
        ) loop
            l_orig_invoice_id := x.invoice_id;
        end loop;

        return ( l_orig_invoice_id );
    end get_original_invoice_id;

    procedure giac_pay_invoice_online (
        p_invoice_id          in number,
        p_entrp_id            in number,
        p_entity_id           in number,
        p_entity_type         in varchar2,
        p_bank_acct_id        in number,
        p_bank_acct_type      in varchar2,
        p_bank_routing_num    in varchar2,
        p_bank_acct_num       in varchar2,
        p_bank_name           in varchar2,
        p_auto_pay            in varchar2,
        p_account_usage       in varchar2,
        p_division_code       in varchar2,
        p_user_id             in number,
        p_bank_status         in varchar2,
        p_giact_verify        in varchar2,
        p_gverify             in varchar2,
        p_gauthenticate       in varchar2,
        p_gresponse           in varchar2,
        p_business_name       in varchar2,
        x_bank_acct_id        out number,
        x_giact_return_status out varchar2,
        x_giact_error_message out varchar2,
        x_return_status       out varchar2,
        x_error_message       out varchar2
    ) is

        l_giact_verify  varchar2(10);
        l_bank_status   varchar2(10);
        l_return_status varchar2(10);
        l_error_message varchar2(1000);
        setup_error exception;
    begin
        pc_log.log_error('pc_invoice.GIAC_PAY_INVOICE_ONLINE  begin p_giact_verify ', p_giact_verify
                                                                                      || ' p_gVerify :='
                                                                                      || p_gverify
                                                                                      || ' p_gAuthenticate :='
                                                                                      || p_gauthenticate
                                                                                      || ' p_bank_status :='
                                                                                      || p_bank_status
                                                                                      || ' P_BANK_ACCT_ID :='
                                                                                      || p_bank_acct_id);

        pc_log.log_error('pc_invoice.GIAC_PAY_INVOICE_ONLINE  **1 p_entity_id ', p_entity_id
                                                                                 || ' P_ENTITY_TYPE :='
                                                                                 || p_entity_type
                                                                                 || 'p_bank_name :='
                                                                                 || p_bank_name
                                                                                 || ' p_bank_acct_type :='
                                                                                 || p_bank_acct_type
                                                                                 || 'p_bank_routing_num :='
                                                                                 || p_bank_routing_num
                                                                                 || 'p_bank_acct_num :='
                                                                                 || p_bank_acct_num);

        x_return_status := 'S';
        x_error_message := null;
   -- If Bank_acct_id is null only then check for the bank status,
   -- else if bank acct id is not null means its an existing active account, so the status would be A.
        if
            nvl(p_giact_verify, '*') = '*'
            and nvl(p_bank_acct_id, 0) = 0
        then
            pc_user_bank_acct.validate_giact_response(
                p_gverify       => p_gverify,
                p_gauthenticate => p_gauthenticate,
                x_giact_verify  => l_giact_verify,
                x_bank_status   => l_bank_status,
                x_return_status => x_giact_return_status,
                x_error_message => x_giact_error_message
            );

            if l_giact_verify = 'R' then
                raise setup_error;
            end if;
        else
            l_bank_status := p_bank_status;
        end if;

        pc_log.log_error('pc_invoice.GIAC_PAY_INVOICE_ONLINE  begin x_giact_return_status :='
                         || x_giact_return_status
                         || 'l_giact_verify ', l_giact_verify
                                               || ' P_ENTRP_ID :='
                                               || p_entrp_id
                                               || ' P_INVOICE_ID :='
                                               || p_invoice_id
                                               || ' l_bank_status :='
                                               || l_bank_status);

        pc_log.log_error('pc_invoice.GIAC_PAY_INVOICE_ONLINE  begin x_giact_error_message :=', x_giact_error_message);
        if ( ( nvl(l_giact_verify, '*') <> '*' )
        or ( nvl(p_bank_acct_id, 0) <> 0 ) ) then --AND l_bank_status = 'A' THEN
            pc_invoice.pay_invoice_online(
                p_invoice_id       => p_invoice_id,
                p_entrp_id         => p_entrp_id,
                p_entity_id        => p_entity_id,
                p_entity_type      => p_entity_type,
                p_bank_acct_id     => p_bank_acct_id,
                p_bank_acct_type   => p_bank_acct_type,
                p_bank_routing_num => p_bank_routing_num,
                p_bank_acct_num    => p_bank_acct_num,
                p_bank_name        => p_bank_name,
                p_auto_pay         => p_auto_pay,
                p_account_usage    => p_account_usage,
                p_division_code    => p_division_code,
                p_user_id          => p_user_id,
                p_business_name    => p_business_name,
                x_bank_acct_id     => x_bank_acct_id,
                x_return_status    => x_return_status,
                x_error_message    => x_error_message
            );

            if nvl(l_bank_status, '*') <> 'A' then
                update ach_transfer
                set
                    status = '6'
                where
                        invoice_id = p_invoice_id
                    and bank_acct_id = x_bank_acct_id;

                update ar_invoice
                set
                    status = 'IN_PROCESS',
                    last_update_date = sysdate
                where
                    invoice_id = p_invoice_id;

                update ar_invoice_lines
                set
                    status = 'IN_PROCESS',
                    last_update_date = sysdate
                where
                    invoice_id = p_invoice_id;

            end if;

        end if;

        pc_log.log_error('pc_invoice.GIAC_PAY_INVOICE_ONLINE  **2.2 l_bank_status ', l_bank_status
                                                                                     || ' p_gresponse :='
                                                                                     || p_gresponse
                                                                                     || 'p_gVerify :='
                                                                                     || p_gverify
                                                                                     || 'p_gAuthenticate :='
                                                                                     || p_gauthenticate
                                                                                     || 'x_bank_acct_id :='
                                                                                     || x_bank_acct_id);

        update bank_accounts
        set
            status = l_bank_status,
            giac_response = p_gresponse,
            giac_verify = p_gverify,
            giac_authenticate = p_gauthenticate
        where
                bank_acct_id = x_bank_acct_id
            and entity_id = p_entity_id;

    exception
        when setup_error then
            x_return_status := 'E';
            x_error_message := x_giact_error_message;
            pc_log.log_error('pc_invoice.GIAC_PAY_INVOICE_ONLINE exception setup_error', x_error_message);
        when others then
            x_return_status := 'O';
            x_error_message := sqlerrm;
            pc_log.log_error('pc_invoice.GIAC_PAY_INVOICE_ONLINE', sqlerrm || dbms_utility.format_error_backtrace);
    end giac_pay_invoice_online;

-- The above procedure will be removed in future will use the below procedure
    procedure giact_pay_invoice_online (
        p_entity_id     in number,
        p_entity_type   in varchar2,
        p_invoice_id    in number,
        p_entrp_id      in number,
        p_auto_pay      in varchar2,
        p_division_code in varchar2,
        p_user_id       in number,
        p_bank_acct_id  in number,
        p_account_usage in varchar2,
        x_return_status out varchar2,
        x_error_message out varchar2
    ) is

        l_bank_acct_id  number;
        l_bank_status   varchar2(10);
        l_bank_message  varchar2(1000);
        l_return_status varchar2(10);
        l_error_message varchar2(1000);
        l_entity_id     number;
        erreur exception;
        setup_error exception;
    begin
        pc_log.log_error('PC_INVOICE.giact_PAY_INVOICE_ONLINE begin  ', 'p_bank_acct_id '
                                                                        || p_bank_acct_id
                                                                        || ' p_entity_id :='
                                                                        || p_entity_id);
        if p_entity_type = 'PERSON' then
            l_entity_id := pc_person.acc_id(p_entity_id);
        else
            l_entity_id := p_entity_id;
        end if;

        for ba in (
            select
                entity_id,
                entity_type,
                bank_acct_id,
                bank_acct_type,
                bank_routing_num,
                bank_acct_num,
                bank_name,
                bank_account_usage,
                business_name,
                status
            from
                bank_accounts
            where
                status in ( 'A', 'P', 'W' )
                and bank_acct_id = p_bank_acct_id
                and entity_id = l_entity_id
        ) loop
            pc_log.log_error('PC_INVOICE.giact_PAY_INVOICE_ONLINE begin  ', 'P_INVOICE_ID '
                                                                            || p_invoice_id
                                                                            || ' P_ENTRP_ID :='
                                                                            || p_entrp_id
                                                                            || ' ba.BANK_ACCT_ID :='
                                                                            || ba.bank_acct_id
                                                                            || ' P_AUTO_PAY :='
                                                                            || p_auto_pay);

            pc_invoice.pay_invoice_online(
                p_invoice_id       => p_invoice_id,
                p_entrp_id         => p_entrp_id,
                p_entity_id        => p_entity_id,
                p_entity_type      => p_entity_type,
                p_bank_acct_id     => ba.bank_acct_id,
                p_bank_acct_type   => ba.bank_acct_type,
                p_bank_routing_num => ba.bank_routing_num,
                p_bank_acct_num    => ba.bank_acct_num,
                p_bank_name        => ba.bank_name,
                p_auto_pay         => p_auto_pay,
                p_account_usage    => p_account_usage,
                p_division_code    => p_division_code,
                p_user_id          => p_user_id,
                p_business_name    => ba.business_name,
                x_bank_acct_id     => l_bank_acct_id,
                x_return_status    => l_return_status,
                x_error_message    => l_error_message
            );

            pc_log.log_error('PC_INVOICE.giact_PAY_INVOICE_ONLINE **1  ', 'l_return_status '
                                                                          || l_return_status
                                                                          || ' ba.BANK_ACCT_ID :='
                                                                          || ba.bank_acct_id
                                                                          || 'ba.status :='
                                                                          || ba.status
                                                                          || ' P_INVOICE_ID :='
                                                                          || p_invoice_id);

            if l_return_status <> 'S' then
                raise erreur;
            end if;
            if nvl(ba.status, '*') <> 'A' then
                update ach_transfer
                set
                    status = '6'
                where
                        invoice_id = p_invoice_id
                    and bank_acct_id = ba.bank_acct_id;

                update ar_invoice
                set
                    status = 'IN_PROCESS',
                    last_update_date = sysdate
                where
                    invoice_id = p_invoice_id;

                update ar_invoice_lines
                set
                    status = 'IN_PROCESS',
                    last_update_date = sysdate
                where
                    invoice_id = p_invoice_id;

            end if;

        end loop;

        x_return_status := 'S';
        x_error_message := 'Success';
    exception
        when erreur then
            x_error_message := l_error_message;
            x_return_status := 'E';
            pc_log.log_error('PC_INVOICE.giact_PAY_INVOICE_ONLINE exception erreur ', 'x_error_message ' || x_error_message);
        when setup_error then
            x_return_status := 'E';
            x_error_message := l_error_message;
            pc_log.log_error('PC_INVOICE.giact_PAY_INVOICE_ONLINE exception setup_error', x_error_message);
        when others then
            x_error_message := sqlerrm;
            x_return_status := 'O';
            pc_log.log_error('PC_INVOICE.giact_PAY_INVOICE_ONLINE exception others ', 'x_error_message ' || x_error_message);
    end giact_pay_invoice_online;

end pc_invoice;
/


-- sqlcl_snapshot {"hash":"26f406b74472c9d8684536d7650bf219c8850a5b","type":"PACKAGE_BODY","name":"PC_INVOICE","schemaName":"SAMQA","sxml":""}