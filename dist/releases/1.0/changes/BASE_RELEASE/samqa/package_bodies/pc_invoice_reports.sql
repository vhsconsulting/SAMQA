-- liquibase formatted sql
-- changeset SAMQA:1754374051906 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_bodies\pc_invoice_reports.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_bodies/pc_invoice_reports.sql:null:1d90c1fc536508df5f31d30e8106e9071281dc61:create

create or replace package body samqa.pc_invoice_reports as

    function get_invoice (
        p_invoice_id   in number,
        p_invoice_type in varchar2
    ) return invoice_tbl
        pipelined
        deterministic
    is
        l_record invoice_rec;
    begin
        for x in (
            select
                ar.invoice_number,
                to_char(ar.invoice_date, 'MM/DD/YYYY')            invoice_date,
                ar.invoice_term,
                ar.coverage_period,
                to_char(ar.invoice_due_date, 'MM/DD/YYYY')        invoice_due_date,
                ( ar.invoice_amount - nvl(ar.void_amount, 0) )    invoice_amount,
                case
                    when ar.plan_type in ( 'HRA', 'FSA', 'HRAFSA' )
                         and ar.invoice_reason = 'FEE' then
                        'Note: Sterling''s FSA and HRA Monthly Administrative Fee Minimum is $125'
                    else
                        ar.comments
                end                                               comments,
                ar.invoice_id,
                ar.auto_pay,
                ar.payment_method,
                ar.billing_name                                   billing_name,
                ar.billing_attn,
                ar.billing_address,
                ar.billing_city,
                ar.billing_zip,
                ar.billing_state,
                ar.start_date,
                ar.end_date,
                round(months_between(ar.end_date, ar.start_date)) no_of_months,
                'Y'                                               detailed_reporting,
                pending_amount
      --    ,NVL(MIN_INV_AMOUNT,0) MIN_INV_AMOUNT
     --     ,NVL(MIN_INV_HRA_AMOUNT,0) MIN_HRA_INV_AMOUNT
                ,
                ar.invoice_status,
                strip_bad(c.name)                                 employer_name,
                ar.paid_amount,
                nvl(
                    pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id),
                    0
                )                                                 bal_due,
                nvl(ar.pending_amount, 0) + nvl(
                    pc_invoice.get_outstanding_balance(ar.entrp_id, ar.entity_type, ar.invoice_reason, ar.invoice_id),
                    0
                )                                                 total_due,
                ac.plan_code,
                ac.acc_num,
                ar.division_code,
                c.entrp_id
            from
                ar_invoice_v ar,
                enterprise   c,
                account      ac
            where
                    invoice_id = p_invoice_id
                and ar.invoice_reason = p_invoice_type
                and c.entrp_id = ac.entrp_id
    --  AND   AR.PLAN_TYPE = NVL(I.PRODUCT_TYPE,AR.PLAN_TYPE)
                and ar.entrp_id = c.entrp_id
        ) loop
            l_record.invoice_number := x.invoice_number;
            l_record.invoice_date := x.invoice_date;
            l_record.invoice_term := x.invoice_term;
            l_record.coverage_period := x.coverage_period;
            l_record.invoice_due_date := x.invoice_due_date;
            l_record.invoice_amount := x.invoice_amount;
            l_record.comments := x.comments;
            l_record.invoice_id := x.invoice_id;
            l_record.auto_pay := x.auto_pay;
            l_record.payment_method := x.payment_method;
            l_record.billing_name := x.billing_name;
            l_record.billing_attn := x.billing_attn;
            l_record.billing_address := x.billing_address;
            l_record.billing_city := x.billing_city;
            l_record.billing_zip := x.billing_zip;
            l_record.billing_state := x.billing_state;
            l_record.start_date := x.start_date;
            l_record.end_date := x.end_date;
            l_record.no_of_months := x.no_of_months;
            l_record.detailed_reporting := x.detailed_reporting;
            l_record.pending_amount := x.pending_amount;
     -- l_record.MIN_INV_AMOUNT := x.MIN_INV_AMOUNT;
    --   l_record.MIN_HRA_INV_AMOUNT := x.MIN_HRA_INV_AMOUNT;
            l_record.acc_num := x.acc_num;
            l_record.division_code := nvl(x.division_code, '-1');
            l_record.division_name := nvl(
                pc_employer_divisions.get_division_name(x.division_code, x.entrp_id),
                'No Division'
            );

            l_record.entrp_id := x.entrp_id;
            l_record.invoice_status := x.invoice_status;
            l_record.employer_name := x.employer_name;
            l_record.paid_amount := x.paid_amount;
            l_record.bal_due := x.bal_due;
            l_record.total_due := x.invoice_amount + x.bal_due - x.paid_amount;
            l_record.current_balance := x.invoice_amount - x.paid_amount;
            for xx in (
                select
                    'Y'
                from
                    ar_invoice_lines
                where
                        invoice_id = x.invoice_id
                    and rate_code = 30
            ) loop
                l_record.pop_comp := 'Y';
            end loop;

            pipe row ( l_record );
        end loop;
    end get_invoice;

    function get_invoice_lines (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2,
        p_source            in varchar2,
        p_product_type      in varchar2
    ) return invoice_line_tbl
        pipelined
        deterministic
    is
        l_record invoice_line_rec;
    begin
        pc_log.log_error('get_invoice_lines', 'p_invoice_line_type' || p_invoice_line_type);
        pc_log.log_error('get_invoice_lines', 'p_product_type' || p_product_type);
        if p_invoice_line_type not in ( 'FLAT_FEE', 'TERMINATION', 'ACTIVE_ADJUSTMENT' ) then
            for x in (
                select
                    b.reason_name             reason_name,
                    a.description
                    || ' '
                    || nvl(
                        pc_lookups.get_meaning(invoice_line_type, 'INVOICE_LINE_TYPE'),
                        ''
                    )                         description,
                    quantity,
                    unit_rate_cost,
                    nvl(total_line_amount, 0) total_line_amount,
                    case
                        when invoice_line_type not in ( 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) then
                            round(nvl(total_line_amount, 0) /(quantity * unit_rate_cost))
                        else
                            1
                    end                       no_of_months,
                    invoice_line_type,
                    a.calculation_type
                from
                    ar_invoice_lines a,
                    pay_reason       b
                where
                        invoice_id = p_invoice_id
			  --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and ( p_invoice_line_type = 'ACTIVE'
                          and invoice_line_type in ( 'ACTIVE', 'CARD', 'OTHERS', 'NEW_ENROLLMENT', 'ADD_TERM',
                                                     'TERMINATION' ) )
                    and a.rate_code = to_char(b.reason_code)
                    and ( b.product_type <> 'HRA'
                          or b.product_type is null )
                    and p_product_type = 'FSA'
                union
                select
                    b.reason_name             reason_name,
                    a.description
                    || ' '
                    || nvl(
                        pc_lookups.get_meaning(invoice_line_type, 'INVOICE_LINE_TYPE'),
                        ''
                    )                         description,
                    quantity,
                    unit_rate_cost,
                    nvl(total_line_amount, 0) total_line_amount,
                    case
                        when invoice_line_type in ( 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) then
                            1
                        else
                            round(nvl(total_line_amount, 0) /(decode(quantity, 0, 1, quantity) * unit_rate_cost))
                    end                       no_of_monthss,
                    invoice_line_type,
                    a.calculation_type
                from
                    ar_invoice_lines a,
                    pay_reason       b
                where
                        invoice_id = p_invoice_id
			  --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and ( p_invoice_line_type = 'ACTIVE'
                          and invoice_line_type in ( 'ACTIVE', 'CARD', 'OTHERS', 'NEW_ENROLLMENT', 'ADD_TERM',
                                                     'TERMINATION' ) )
                    and a.rate_code = to_char(b.reason_code)
                    and ( b.product_type <> 'HRA'
                          or b.product_type is null )
                    and p_product_type not in ( 'HRA', 'FSA' )
                union
                select
                    b.reason_name             reason_name,
                    a.description
                    || ' '
                    || nvl(
                        pc_lookups.get_meaning(invoice_line_type, 'INVOICE_LINE_TYPE'),
                        ''
                    )                         description,
                    quantity,
                    unit_rate_cost,
                    nvl(total_line_amount, 0) total_line_amount,
                    case
                        when invoice_line_type in ( 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) then
                            no_of_months
                        else
                            round(nvl(total_line_amount, 0) /(decode(quantity, 0, 1, quantity) * unit_rate_cost))
                    end                       no_of_monthss,
                    invoice_line_type,
                    a.calculation_type
                from
                    ar_invoice_lines a,
                    pay_reason       b
                where
                        invoice_id = p_invoice_id
			  --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and ( p_invoice_line_type = 'ACTIVE'
                          and invoice_line_type in ( 'ACTIVE', 'CARD', 'OTHERS', 'NEW_ENROLLMENT', 'ADD_TERM' ) )
                    and a.rate_code = to_char(b.reason_code)
                    and p_product_type <> 'FSA'
                    and b.product_type = 'HRA'
                union
                select
                    b.reason_name             reason_name,
                    a.description
                    || ' '
                    || nvl(
                        pc_lookups.get_meaning(invoice_line_type, 'INVOICE_LINE_TYPE'),
                        ''
                    )                         description,
                    quantity,
                    unit_rate_cost,
                    nvl(total_line_amount, 0) total_line_amount,
                    case
                        when invoice_line_type in ( 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) then
                            1
                        else
                            round(nvl(total_line_amount, 0) /(decode(quantity, 0, 1, quantity) * unit_rate_cost))
                    end                       no_of_monthss,
                    invoice_line_type,
                    a.calculation_type
                from
                    ar_invoice_lines a,
                    pay_reason       b
                where
                        invoice_id = p_invoice_id
			  --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and ( p_invoice_line_type <> 'ACTIVE'
                          and invoice_line_type = p_invoice_line_type )
                    and a.rate_code = to_char(b.reason_code)
                    and ( b.plan_type <> 'HRA'
                          or b.plan_type is null )
                    and p_product_type = 'FSA'
                union
                select
                    b.reason_name             reason_name,
                    a.description
                    || ' '
                    || nvl(
                        pc_lookups.get_meaning(invoice_line_type, 'INVOICE_LINE_TYPE'),
                        ''
                    )                         description,
                    quantity,
                    unit_rate_cost,
                    nvl(total_line_amount, 0) total_line_amount,
                    case
                        when invoice_line_type in ( 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) then
                            1
                        else
                            round(nvl(total_line_amount, 0) /(decode(quantity, 0, 1, quantity) * unit_rate_cost))
                    end                       no_of_monthss,
                    invoice_line_type,
                    a.calculation_type
                from
                    ar_invoice_lines a,
                    pay_reason       b
                where
                        invoice_id = p_invoice_id
			  --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and ( p_invoice_line_type <> 'ACTIVE'
                          and invoice_line_type = p_invoice_line_type )
                    and a.rate_code = to_char(b.reason_code)
                    and p_product_type <> 'FSA'
                    and b.product_type = 'HRA'
            ) loop
                l_record.reason_name := x.reason_name;
                l_record.description := x.description;
                l_record.quantity := x.quantity;
                l_record.unit_rate_cost := x.unit_rate_cost;
                l_record.total_line_amount := x.total_line_amount;
                l_record.no_of_months := x.no_of_months;
                l_record.invoice_line_type := x.invoice_line_type;
                l_record.calculation_type := x.calculation_type;
                pipe row ( l_record );
            end loop;
        end if;

        if p_invoice_line_type = 'FLAT_FEE' then
            for x in (
                select
                    b.reason_name             reason_name,
                    a.description
                    || ' '
                    || nvl(
                        pc_lookups.get_meaning(invoice_line_type, 'INVOICE_LINE_TYPE'),
                        ''
                    )                         description,
                    quantity,
                    unit_rate_cost,
                    nvl(total_line_amount, 0) total_line_amount,
                    case
                        when invoice_line_type not in ( 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) then
                            round(nvl(total_line_amount, 0) /(quantity * unit_rate_cost))
                        else
                            1
                    end                       no_of_months,
                    invoice_line_type,
                    a.calculation_type
                from
                    ar_invoice_lines a,
                    pay_reason       b,
                    ar_invoice       ai
                where
                        a.invoice_id = p_invoice_id
			  --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and a.invoice_id = ai.invoice_id
                    and ( p_invoice_line_type = 'FLAT_FEE'
                          and invoice_line_type in ( 'FLAT_FEE', 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) )
                    and a.rate_code = to_char(b.reason_code)
                    and nvl(
                        nvl(a.product_type, b.product_type),
                        ai.plan_type
                    ) = p_product_type
            ) loop
                l_record.reason_name := x.reason_name;
                l_record.description := x.description;
                l_record.quantity := x.quantity;
                l_record.unit_rate_cost := x.unit_rate_cost;
                l_record.total_line_amount := x.total_line_amount;
                l_record.no_of_months := x.no_of_months;
                l_record.invoice_line_type := x.invoice_line_type;
                l_record.calculation_type := x.calculation_type;
                if l_record.calculation_type = 'PERCENTAGE' then
                    l_record.unit_rate_cost := x.unit_rate_cost * 100;
                end if;

                pipe row ( l_record );
            end loop;
        end if;

        if p_invoice_line_type = 'TERMINATION' then
            for x in (
                select
                    p.last_name
                    || ','
                    || p.first_name                                             pers_name,
                    c.description,
                    pc_lookups.get_meaning(invoice_reason, 'INVOICE_LINE_TYPE') invoice_reason,
                    c.unit_rate_cost,
                    a.invoice_days                                              no_of_months,
                    a.invoice_days * c.unit_rate_cost                           total_amount
                from
                    ar_invoice_lines             c,
                    invoice_distribution_summary a,
                    person                       p,
                    pay_reason                   d
                where
                        a.invoice_id = p_invoice_id
                    and c.invoice_line_id = a.invoice_line_id
                    and a.invoice_id = c.invoice_id
                    and nvl(invoice_reason, '-1') = 'TERMINATION'
                    and a.pers_id = p.pers_id
			  --AND    c.STATUS <> 'VOID'
                    and c.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and a.rate_code = to_char(d.reason_code)
            ) loop
                l_record.reason_name := x.invoice_reason;
                l_record.description := x.description;
                l_record.unit_rate_cost := x.unit_rate_cost;
                l_record.total_line_amount := x.total_amount;
                l_record.no_of_months := x.no_of_months;
                pipe row ( l_record );
            end loop;
        end if;

        if p_invoice_line_type = 'ACTIVE_ADJUSTMENT' then
            for x in (
                select
                    p.last_name
                    || ','
                    || p.first_name                         pers_name,
                    d.reason_name                           description,
                    to_char(a.enrolled_date, 'MM/DD/YYYY')  enrolled_date,
                    to_char(a.effective_date, 'MM/DD/YYYY') effective_date,
                    c.unit_rate_cost,
                    c.rate_code,
                    c.invoice_days                          no_of_months,
                    c.invoice_days * c.unit_rate_cost       total_amount
                from
                    (
                        select
                            c.pers_id,
                            e.unit_rate_cost,
                            c.rate_code,
                            c.invoice_days
                        from
                            invoice_distribution_summary c,
                            ar_invoice_lines             e
                        where
                                c.invoice_line_id = e.invoice_line_id
                            and e.invoice_id = c.invoice_id
					   --AND e.STATUS <> 'VOID'
                            and e.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                            and e.invoice_id = p_invoice_id
                            and e.invoice_line_type = 'ACTIVE_ADJUSTMENT'
                            and c.invoice_kind = 'ACTIVE_ADJUSTMENT'
                    )          c,
                    (
                        select distinct
                            pers_id,
                            trunc(enrolled_date)  enrolled_date,
                            trunc(effective_date) effective_date,
                            invoice_id,
                            invoice_days
                        from
                            ar_invoice_dist_plans
                        where
                                invoice_kind = 'ACTIVE_ADJUSTMENT'
                            and invoice_id = p_invoice_id
                    )          a,
                    person     p,
                    pay_reason d
                where
                        a.invoice_id = p_invoice_id
                    and a.pers_id = c.pers_id
                    and a.pers_id = p.pers_id
                    and c.rate_code = to_char(d.reason_code)
				 -- AND   D.PLAN_TYPE = p_product_type   commneted by joshi for 11009  and added below statment.
                    and d.product_type = p_product_type
                order by
                    d.reason_name,
                    p.last_name
            ) loop
                l_record.description := x.description;
                l_record.unit_rate_cost := x.unit_rate_cost;
                l_record.total_line_amount := x.total_amount;
                l_record.no_of_months := x.no_of_months;
                l_record.enrolled_date := x.enrolled_date;
                l_record.effective_date := x.effective_date;
                l_record.rate_code := x.rate_code;
                l_record.pers_name := x.pers_name; -- Added by Joshi for 11009.
                pipe row ( l_record );
            end loop;
        end if;

    end get_invoice_lines;

    function get_erisacobrapop_lines (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2,
        p_source            in varchar2,
        p_product_type      in varchar2
    ) return invoice_line_tbl
        pipelined
        deterministic
    is
        l_record invoice_line_rec;
    begin
        if p_invoice_line_type = 'FEE' then
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
                    case
                        when invoice_line_type not in ( 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) then
                            unit_rate_cost
                        else
                            unit_rate_cost * 100
                    end                       unit_rate_cost,
                    nvl(total_line_amount, 0) total_line_amount,
                    invoice_line_type,
                    case
                        when invoice_line_type not in ( 'SETUP_SERVICE_CHARGE', 'RENEWAL_SERVICE_CHARGE' ) then
                            round(nvl(total_line_amount, 0) /(quantity * unit_rate_cost))
                        else
                            1
                    end                       no_of_months,
                    a.calculation_type,
                    rate_code -- Added by Joshi for 8741.
                from
                    ar_invoice_lines a,
                    pay_reason       b
                where
                        invoice_id = p_invoice_id
		  --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and nvl(invoice_line_type, '-1') in ( 'ACTIVE', 'CARD', 'OTHERS', 'FLAT_FEE', 'SETUP_SERVICE_CHARGE',
                                                          'RENEWAL_SERVICE_CHARGE' )
                    and a.rate_code = to_char(b.reason_code)
            ) loop
                l_record.description := x.description;
                l_record.unit_rate_cost := x.unit_rate_cost;
                l_record.total_line_amount := x.total_line_amount;
                l_record.no_of_months := x.no_of_months;
                l_record.quantity := x.quantity;
                l_record.invoice_line_type := x.invoice_line_type;
                l_record.calculation_type := x.calculation_type;
                l_record.rate_code := x.rate_code; -- Added by Joshi for 8741
           -- l_record.RATE_CODE := x.RATE_CODE;
                pipe row ( l_record );
            end loop;

        end if;
    end get_erisacobrapop_lines;

    function get_funding_invoice_lines (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2,
        p_source            in varchar2,
        p_product_type      in varchar2
    ) return invoice_line_tbl
        pipelined
        deterministic
    is
        l_record invoice_line_rec;
    begin
        if p_invoice_line_type = 'FUNDING' then
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
                    nvl(total_line_amount, 0)                                     total_line_amount,
                    round(nvl(total_line_amount, 0) /(quantity * unit_rate_cost)) no_of_months,
                    a.rate_code
                from
                    ar_invoice_lines a,
                    pay_reason       b
                where
                        invoice_id = p_invoice_id
          --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and nvl(invoice_line_type, '-1') in ( 'FUNDING', 'OTHERS', 'FLAT_FEE' )
                    and a.rate_code = to_char(b.reason_code)
            ) loop
                l_record.description := x.description;
                l_record.unit_rate_cost := x.unit_rate_cost;
                l_record.total_line_amount := x.total_line_amount;
                l_record.no_of_months := x.no_of_months;
                l_record.quantity := x.quantity;
                l_record.rate_code := x.rate_code;
                pipe row ( l_record );
            end loop;

        end if;
    end get_funding_invoice_lines;

    function get_claim_invoice_lines (
        p_invoice_id        in number,
        p_invoice_line_type in varchar2,
        p_source            in varchar2,
        p_product_type      in varchar2
    ) return invoice_line_tbl
        pipelined
        deterministic
    is
        l_record invoice_line_rec;
    begin
        if p_invoice_line_type = 'CLAIM' then
            for x in (
                select
                    a.description,
                    quantity,
                    nvl(total_line_amount, 0) total_line_amount
                from
                    ar_invoice_lines a,
                    pay_reason       b
                where
                        invoice_id = p_invoice_id
                      --AND A.STATUS <> 'VOID'
                    and a.status not in ( 'VOID', 'CANCELLED' )   -- Added Cancelled by Swamy for Ticket#9860 on 26/04/2021
                    and invoice_line_type in ( 'ADJUSTMENT', 'CLAIM', 'FLAT_FEE' )
                    and a.rate_code = to_char(b.reason_code)
            ) loop
                l_record.description := x.description;
                l_record.total_line_amount := x.total_line_amount;
                l_record.quantity := x.quantity;
                pipe row ( l_record );
            end loop;

        end if;
    end get_claim_invoice_lines;

    function get_tax (
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
    end get_tax;
    -- 03/11/2017:Vanitha:Invoice notification enhancement

    procedure send_inv_remind_notif is

        v_entrp_id          number;
        v_description       varchar2(3200);
        v_template_name     varchar2(3200);
        v_template_subject  varchar2(3200);
        v_template_body     varchar2(32000);
        v_invoice_id        number;
        inv_cur             sys_refcursor;
        l_notif_id          number;
        l_email             varchar2(4000);
        num_tbl             pc_notifications.number_tbl;
        l_send_notification varchar2(1) := 'Y';
        l_notice_type       varchar2(100);
        l_subject           varchar2(500);
    begin
        for x in (
            select
                ns.entrp_id,
                ns.description,
                nt.template_name,
                nt.template_subject,
                template_body,
                ' accountsreceivable@sterlingadministration.com' from_address,
                to_address,
                nt.cc_address,
                ( 'SELECT '
                  || trigger_column
                  || ' FROM '
                  || trigger_table
                  || ' WHERE '
                  || trigger_condition
                  || ' '
                  || trigger_on )                                  inv_sql
            from
                notification_schedule ns,
                notification_template nt
            where
                    ns.notif_template_id = nt.notif_template_id
                and ns.send_notification = 'Y'
                and ns.notification_entity = 'INVOICE'  -- Added by Joshi for  12396. should get only invoice related notifications.
        ) loop
            begin
                inv_cur := get_cursor(x.inv_sql);
                l_email := null;
                l_notice_type := x.description;
                pc_log.log_error('SEND_INV_REMIND_NOTIF begin l_Notice_Type ', l_notice_type);
                loop
                    fetch inv_cur into v_invoice_id;
                    exit when inv_cur%notfound;

         --   l_email := SUBSTR(PC_CONTACT.get_invoice_contact_email (v_invoice_id),1,4000);

                    for xx in (
                        select
                            ar.invoice_due_date,
                            trunc(sysdate) - trunc(ar.invoice_due_date) invoice_age,
                            ar.entity_id,
                            ar.entity_type,
                            ar.acc_id,
                            ac.acc_num    -- Added by Swamy #11699
                            ,
                            ar.invoice_reason,
                            case
                                when ar.plan_type in ( 'HRA', 'FSA', 'HRAFSA', 'FSAHRA' ) then
                                    'HRAFSA'
                                when ar.plan_type = 'COBRA' then
                                    'COBRA'
                                else
                                    'COMPLIANCE'
                            end                                         product_code,
                            case
                                when ar.invoice_reason = 'FEE'     then
                                    'FEE_BILLING'
                                when ar.invoice_reason = 'FUNDING' then
                                    'FUND_BILLING'
                                when ar.invoice_reason = 'CLAIM'   then
                                    'CLAIM_BILLING'
                            end                                         billing_code,
                            pc_lookups.get_meaning(
                                pc_account.get_account_type(ar.acc_id),
                                'ACCOUNT_TYPE'
                            )                                           account_type,
                            ip.invoice_frequency,
                            pc_entrp.get_entrp_name(ar.entity_id)
                            || '('
                            || pc_entrp.get_acc_num(ar.entity_id)
                            || ')'                                      company_name -- Added by Joshi for 10974
                        from
                            ar_invoice         ar,
                            invoice_parameters ip,
                            account            ac    -- Added by Swamy for Ticket#11743
                        where
                                ar.invoice_id = v_invoice_id
                            and ar.status = 'PROCESSED'
                            and ar.invoice_reason = 'FEE'
                            and ar.invoice_reason = ip.invoice_type
                            and ar.rate_plan_id = ip.rate_plan_id
                            and nvl(ip.division_code, '-1') = nvl(ar.division_code, '-1')
                            and ip.status = 'A'
                            and ip.send_invoice_reminder = 'Y'
                            and ar.entity_type = 'EMPLOYER'
                            and ac.entrp_id = ar.entity_id    -- Added by Swamy for Ticket#11743
                            and ip.entity_id = ac.entrp_id     -- Added by Swamy for Ticket#11743
                            and ac.account_type <> 'HSA'       -- Added by Swamy for Ticket#11743
                    ) loop
              -- Added by Joshi for 9830. For FSA/HRA invoice reminder should not go if GA Monthly
                  -- invoice statement is generated for the invoice
                        l_send_notification := 'Y';

                  --  IF XX.PRODUCT_CODE = 'HRAFSA' AND XX.billing_code = 'FEE_BILLING' THEN
                  -- Commented above and added below by Joshi for 10744. for cobra also notification should not be sent
                        if (
                            xx.product_code = 'HRAFSA'
                            and xx.billing_code = 'FEE_BILLING'
                        )
                        or (
                            xx.account_type = 'COBRA'
                            and xx.invoice_frequency = 'MONTHLY'
                        ) then
                            for y in (
                                select
                                    nvl(generate_combined_stmt, 'N') generate_combined_stmt_flag
                                from
                                    general_agent ga,
                                    account       a
                                where
                                        a.acc_id = xx.acc_id
                                    and a.ga_id = ga.ga_id
                            ) loop
                                if y.generate_combined_stmt_flag = 'Y' then
                                    l_send_notification := 'N';
                                end if;
                            end loop;

                        end if;

                        dbms_output.put_line('v_invoice_id: '
                                             || v_invoice_id
                                             || 'l_send_notification:'
                                             || l_send_notification);
                        pc_log.log_error('SEND_INV_REMIND_NOTIF l_Notice_Type **inside ', l_notice_type);
                 -- Added by Joshi for 9830.
                        if l_send_notification = 'Y' then
                            if l_notice_type = 'FINAL_NOTICE' then -- Added by Jaggi #11699
                                pc_log.log_error('SEND_INV_REMIND_NOTIF **1 ', l_notice_type);
                                for xxx in (
                                    select
                                        listagg(email, ',') within group(
                                        order by
                                            email
                                        ) email
                                    from
                                        table ( pc_contact.get_notify_all_contacts(
                                            pc_entrp.get_tax_id(xx.entity_id),
                                            xx.billing_code,
                                            xx.product_code,
                                            v_invoice_id
                                        ) )
                                ) loop
                                    l_email := substr(xxx.email, 1, 4000);
                                end loop;

                            else
                                pc_log.log_error('SEND_INV_REMIND_NOTIF **2 ', l_notice_type);
                                for xxx in (
                                    select
                                        listagg(email, ',') within group(
                                        order by
                                            email
                                        ) email
                                    from
                                        table ( pc_contact.get_notify_emails(
                                            pc_entrp.get_tax_id(xx.entity_id),
                                            xx.billing_code,
                                            xx.product_code,
                                            v_invoice_id
                                        ) )
                                ) loop
                                    l_email := substr(xxx.email, 1, 4000);
                                end loop;

                            end if;

                            for xxx in (
                                select
                                    user_id
                                from
                                    online_users
                                where
                                        emp_reg_type = 2
                                    and tax_id = pc_entrp.get_tax_id(xx.entity_id)
                                    and user_status <> 'D'
                            ) loop
                                num_tbl(num_tbl.count + 1) := xxx.user_id;
                            end loop;

                            pc_notifications.add_notify_users(num_tbl, l_notif_id);
                            if l_notice_type <> 'URGENT_NOTICE' then -- Added by Swamy #11699
                                l_subject := replace(
                                    replace(
                                        replace(x.template_subject, '<<PRODUCT>>', xx.account_type),
                                        '<<INVOICE_NUMBER>>',
                                        v_invoice_id
                                    ),
                                    '<<COMPANY_NAME>>',
                                    xx.company_name
                                );
                            else
                                l_subject := replace(
                                    replace(
                                        replace(x.template_subject, '<<PRODUCT>>', xx.account_type),
                                        '<<INVOICE_DUE_DAY>>',
                                        xx.invoice_age
                                    ),
                                    '<<COMPANY_NAME>>',
                                    xx.company_name
                                );
                            end if;

                            if nvl(l_email, x.to_address) is not null then
                                pc_notifications.insert_notifications(
                                    p_from_address    => x.from_address,
                                    p_to_address      => nvl(l_email, x.to_address),
                                    p_cc_address      => x.cc_address
                     --   ,P_SUBJECT      => REPLACE(REPLACE(x.TEMPLATE_SUBJECT,'<<PRODUCT>>',XX.account_type)
                    --                          ,'<<INVOICE_DUE_DAY>>',xx.invoice_age)

                      --,P_SUBJECT      => REPLACE( REPLACE(REPLACE(x.TEMPLATE_SUBJECT,'<<PRODUCT>>',XX.account_type)
                        --                            ,'<<INVOICE_DUE_DAY>>',xx.invoice_age),'<<COMPANY_NAME>>', XX.COMPANY_NAME) -- commented above and added line by Joshi for  10974

                     --    ,P_SUBJECT      => REPLACE( REPLACE(REPLACE(x.TEMPLATE_SUBJECT,'<<PRODUCT>>',XX.account_type)
                      --                              ,'<<INVOICE_NUMBER>>',v_invoice_id),'<<COMPANY_NAME>>', XX.COMPANY_NAME) -- Added by Swamy #11699
                                    ,
                                    p_subject         => l_subject,
                                    p_message_body    => x.template_body,
                                    p_acc_id          => xx.acc_id,
                                    p_user_id         => 0,
                                    x_notification_id => l_notif_id
                                );

                                if l_notice_type = 'FINAL_NOTICE' then -- Added by Swamy #11699
                                    pc_notifications.set_token('ACCOUNT_NUMBER',
                                                               trim(xx.acc_num),
                                                               l_notif_id);
                                end if;

                                pc_invoice.insert_inv_notif(
                                    p_invoice_id      => v_invoice_id,
                                    p_invoice_age     => xx.invoice_age,
                                    p_notif_type      => x.description,
                                    p_email           => nvl(l_email, x.to_address),
                                    p_notification_id => l_notif_id,
                                    p_template_name   => x.template_name
                                );

                            end if;

                        end if; -- Added by Joshi for 9830.
                    end loop;

                end loop;

            exception
                when others then
                    pc_log.log_error('SEND_INV_REMIND_NOTIF', x.template_name
                                                              || ' '
                                                              || sqlerrm);
                    raise;
            end;
        end loop;

        close inv_cur;
    end send_inv_remind_notif;

    function get_invoice_notify return pc_notifications.notification_t
        pipelined
        deterministic
    is
        l_record_t pc_notifications.notification_rec;
    begin
        for x in (
            select
                en.to_address,
                en.from_address,
                ain.template_name,
                en.subject,
                en.message_body,
                en.notification_id,
                ain.invoice_id,
                ain.invoice_notif_id,
                acc.account_type
            from
                ar_invoice_notifications ain,
                email_notifications      en,
                ar_invoice               ar,
                account                  acc
            where
                    ain.notification_id = en.notification_id
	      -- AND    AIN.MAILED_DATE IS NULL
                and ar.invoice_id = ain.invoice_id
                and acc.acc_num = ar.acc_num
                and en.mail_status = 'OPEN'
                and ain.template_name in ( 'INVOICE_URGENT_NOTICE', 'INVOICE_FINAL_NOTICE', 'INVOICE_COURTESY_NOTICE' )
        ) loop
            l_record_t.to_address := x.to_address;
            l_record_t.from_address := x.from_address;
            l_record_t.template_name := x.template_name;
            l_record_t.subject := x.subject;
            l_record_t.message_body := x.message_body;
            l_record_t.notification_id := x.notification_id;
            l_record_t.entity_id := x.invoice_id;
            l_record_t.invoice_notify_id := x.invoice_notif_id;
            l_record_t.account_type := x.account_type;
            pipe row ( l_record_t );
        end loop;
    end get_invoice_notify;
  -- 03/11/2017:Vanitha:Invoice notification enhancement

 -- Invoice Report Schedule
    procedure monthly_ar_report (
        p_report_type in varchar2,
        p_start_date  in date,
        p_end_date    in date
    ) is

        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_file_name    varchar2(32000);
        l_rows         number;
    begin
        if p_report_type = 'AR_REPORT' then
            l_html_message := ' Monthly AR Report generated on ' || to_char(sysdate, 'MM/DD/YYYY');
        end if;

        l_sql := 'select   "AR_INVOICE"."INVOICE_NUMBER" as "Invoice Number",
         "AR_INVOICE"."INVOICE_ID" as "Invoice #",
         "AR_INVOICE"."START_DATE" as "Start Date",
         "AR_INVOICE"."END_DATE" as "End Date",
         "ACC"."ACC_NUM" as "Account Number",
         "ACC"."START_DATE" as "Start Date",
          ''"''||PC_ENTRP.get_entrp_name(ENTITY_ID)||''"'' "Employer Name",
         "AR_INVOICE"."INVOICE_DATE" as "Invoice Date",
         "AR_INVOICE"."INVOICE_DUE_DATE" as "Invoice Due Date",
         "AR_INVOICE"."CANCELLED_DATE" as "Cancelled Date",
         "AR_INVOICE"."INVOICE_AMOUNT" as "Invoice Amount",
         "AR_INVOICE"."PAID_AMOUNT" as "Paid Amount",
         "AR_INVOICE"."PENDING_AMOUNT" as "Pending Amount",
         "AR_INVOICE"."REFUND_AMOUNT" AS "Refund Amount",
         "AR_INVOICE"."VOID_AMOUNT" as "Void Amount",
         PC_LOOKUPS.GET_MEANING ("AR_INVOICE"."INVOICE_TERM",''PAYMENT_TERM'') as "INVOICE_TERM",
         PC_LOOKUPS.GET_MEANING ("AR_INVOICE"."STATUS",''INVOICE_STATUS'') as "STATUS",
         AR_INVOICE.PLAN_TYPE "Plan Type", acc.account_type "Account Type"
       from    "AR_INVOICE" "AR_INVOICE" , ACCOUNT ACC WHERE 1 = 1
       AND      AR_INVOICE.INVOICE_REASON= ''FEE''
       AND      ACC.ENTRP_ID IS NOT NULL
        AND     AR_INVOICE.ENTITY_ID = ACC.ENTRP_ID';
        if p_report_type = 'AR_REPORT' then
            l_sql := l_sql
                     || '  AND    AR_INVOICE.INVOICE_DATE  >= '''
                     || p_start_date
                     || '''
                              AND   AR_INVOICE.INVOICE_DATE <= '''
                     || p_end_date
                     || '''';

            l_sql := l_sql || '   AND    AR_INVOICE.STATUS NOT IN (''CANCELLED'',''DRAFT'',''GENERATED'') ';
        elsif p_report_type = 'GENERATED' then
            l_sql := l_sql || '   AND    AR_INVOICE.STATUS  IN ( ''GENERATED'') ';
        end if;

        l_file_name :=
            case
                when p_report_type = 'AR_REPORT' then
                    'invoice_ar_report_'
                    || to_char(sysdate, 'MMDDYYYY')
                    || '.csv'
                else 'generated_ar_report_'
                     || to_char(sysdate, 'MMDDYYYY')
                     || '.csv'
            end;

        dbms_output.put_line(l_sql);
        l_rows := dump_csv(l_sql, ',', 'REPORT_DIR', l_file_name);
       --IF l_rows > 0 THEN

        pc_notifications.insert_reports(
            case
                when p_report_type = 'AR_REPORT' then
                    'AR Invoice Report ' || to_char(sysdate, 'MM/DD/YYYY')
                else 'Generated Invoice Report ' || to_char(sysdate, 'MM/DD/YYYY')
            end,
            '/u01/app/oracle/oradata/report/',
            l_file_name,
            'INVOICE_REPORTS',
            l_html_message);

       --END IF;
        commit;
    exception
        when others then
            dbms_output.enable;
            dbms_output.put_line(sqlerrm);
            raise;
    end monthly_ar_report;

    procedure monthly_revenue_report (
        p_start_date   in date,
        p_end_date     in date,
        p_account_type in varchar2,
        p_report_type  in varchar2
    ) is

        l_html_message varchar2(32000);
        l_sql          varchar2(32000);
        l_rows         number;
        v_email        varchar2(4000) := 'IT-team@sterlingadministration.com';
        l_file_name    varchar2(32000);
    begin
        if p_report_type = 'REVENUE_REPORT' then
            l_html_message := 'Monthly Revenue Report for '
                              || p_account_type
                              || ' generated on '
                              || to_char(sysdate, 'MM/DD/YYYY');
        elsif p_report_type = 'VOID_REPORT' then
            l_html_message := 'Monthly Void Report for '
                              || p_account_type
                              || ' generated on '
                              || to_char(sysdate, 'MM/DD/YYYY');
        else
            l_html_message := 'Monthly Generated Invoice Report for generated on ' || to_char(sysdate, 'MM/DD/YYYY');
        end if;

        dbms_output.put_line('Here' || p_start_date);
        l_sql := 'SELECT    A."INVOICE_NUMBER" as "Invoice Number",
        A."INVOICE_ID" as "Invoice #",
           ''"''||PC_ENTRP.get_entrp_name(ENTITY_ID)||''"'' "Employer Name",
         TO_CHAR(A."START_DATE",''MM/DD/YYYY'') as "Start Date",
         TO_CHAR(A."END_DATE",''MM/DD/YYYY'') as "End Date",
         TO_CHAR(D."REG_DATE",''MM/DD/YYYY'') as "Reg Date",
         TO_CHAR(A."INVOICE_DATE",''MM/DD/YYYY'') as "Invoice Date",
         TO_CHAR(A."INVOICE_DUE_DATE",''MM/DD/YYYY'') as "Invoice Due Date",
         TO_CHAR(A."APPROVED_DATE",''MM/DD/YYYY'') as "Approved Date",
         TO_CHAR(A."VOID_DATE",''MM/DD/YYYY'') as "Void Date",
         "D"."ACC_NUM" as "Account Number",
         "D"."START_DATE" as "Start Date",
          ''"''||PC_ENTRP.get_entrp_name(ENTITY_ID)||''"'' "Employer Name",
      /*   ''"''||FORMAT_MONEY(A."INVOICE_AMOUNT")||''"'' as "Invoice Amount",
         ''"''||FORMAT_MONEY(A."PAID_AMOUNT")||''"'' as "Paid Amount",
         ''"''||FORMAT_MONEY(A."PENDING_AMOUNT")||''"'' as "Pending Amount",
         ''"''||FORMAT_MONEY(A."REFUND_AMOUNT")||''"'' AS "Refund Amount",*/
              ''"''|| TO_CHAR(A."INVOICE_AMOUNT",''fmL99G999D00'')||''"''as "Invoice Amount",
              ''"''|| TO_CHAR(A.PAID_AMOUNT,''fmL99G999D00'')||''"'' as "Paid Amount",
              ''"''|| TO_CHAR(A.PENDING_AMOUNT,''fmL99G999D00'')||''"'' as "Pending Amount",
             ''"''||TO_CHAR(A.REFUND_AMOUNT,''fmL99G999D00'')||''"'' as "Refund Amount",
          A.INVOICE_TERM AS "Invoice Term",
          A.PAYMENT_METHOD as "Payment Method",
          A.BILLING_STATE as "Billing State",
         /* ''"''||A.BILLING_NAME||''"'' as "Billing Name",
          ''"''||A.BILLING_ATTN||''"'' "Billing Attn",
          ''"''||A.BILLING_ADDRESS||'',''||A.BILLING_CITY||'',''||A.BILLING_STATE||'' ''||A.BILLING_ZIP||''"''  "Billing Address",*/ --Sk commented due to format issues 04/06/2023
           DECODE(A.PLAN_TYPE,''FSA'',''FSA'',''HRAFSA'',''Stacked'',''HRA'',''HRA'',D.ACCOUNT_TYPE) "Account Type",
           C.REASON_NAME "Reason Name",
         /*  ''"''||FORMAT_MONEY(B.TOTAL_LINE_AMOUNT)||''"'' "Total Line Amount",
           ''"''||FORMAT_MONEY(B.VOID_AMOUNT)||''"'' "Voided Line Amount",*/
           ''"''||TO_CHAR(B.TOTAL_LINE_AMOUNT,''fmL99G999D00'')||''"'' as "Total Line Amount",
           ''"''||TO_CHAR(B.VOID_AMOUNT,''fmL99G999D00'')||''"'' as "Voided Line Amount",
           TO_CHAR(PC_BENEFIT_PLANS.GET_EFFECTIVE_DATE(A.ENTITY_ID,A.START_DATE,A.END_DATE, A.PLAN_TYPE) ,''MM/DD/YYYY'') "Effective Date",
           DECODE(b.STATUS,''GENERATED'',''In Process'',''PROCESSED'',''Approved'',''POSTED'',''Got Payment'',''VOID'',''Void'',''CANCELLED'',''Cancelled'') "Line Status",/*Sk Added Cancelled Status on 06/10/2021*/
           PC_SALES_TEAM.GET_CUST_SRVC_REP_NAME_FOR_ER(D.ENTRP_ID) "Client Service Rep",
           PC_ACCOUNT.IS_STACKED_ACCOUNT(D.ENTRP_ID) "Stacked Account" ,
           PC_LOOKUPS.GET_MEANING(B.INVOICE_LINE_TYPE, ''INVOICE_LINE_TYPE'') "Invoice Line Type",
           PC_LOOKUPS.GET_MEANING (A.STATUS,''INVOICE_STATUS'') "STATUS",
            PC_ACCOUNT.GET_SALESREP_NAME( A.SALESREP_ID)SALESREP,
           ( Case WHEN  b.Rate_code in(89,264)  and exists (select * from ar_invoice_lines where invoice_id=
      b.invoice_id and rate_code IN (1,100,43,44)) THEN  ''SETUPDISCOUNT''
       WHEN B.rate_code=89 and exists (select * from ar_invoice_lines where invoice_id=
b.invoice_id and rate_code IN (30,45,46)) THEN  ''RENEWALDISCOUNT''
ELSE
NULL
END)INVOICE_TYPE,
 ''"''||A.BILLING_NAME||''"'' as "Billing Name",
          ''"''||A.BILLING_ATTN||''"'' "Billing Attn"
      FROM   AR_INVOICE A, AR_INVOICE_LINES B,PAY_REASON C, ACCOUNT D
      WHERE  A.INVOICE_ID = B.INVOICE_ID
      AND    A.ACC_ID = D.ACC_ID
      AND    B.RATE_CODE = TO_CHAR(C.REASON_CODE)
      AND    a.INVOICE_REASON= ''FEE'' ';
        if p_report_type = 'REVENUE_REPORT' then
            l_sql := l_sql || '   AND    A.STATUS NOT IN (''CANCELLED'',''DRAFT'',''GENERATED'') ';
            l_sql := l_sql
                     || '  AND    A.INVOICE_DATE  >= '''
                     || p_start_date
                     || '''
                               AND    A.INVOICE_DATE <= '''
                     || p_end_date
                     || '''
                               AND    d.ACCOUNT_TYPE   = '''
                     || p_account_type
                     || '''';

        elsif p_report_type = 'VOID_REPORT' then
            l_sql := l_sql
                     || '   AND    ((A.STATUS  = ''VOID'') '
                     || '  OR      (A.STATUS NOT IN (''CANCELLED'',''DRAFT'',''GENERATED'')
                                 AND   B.STATUS = ''VOID''))';
            l_sql := l_sql
                     || '  AND    A.VOID_DATE  >= '''
                     || p_start_date
                     || '''
                               AND    A.VOID_DATE <= '''
                     || p_end_date
                     || '''
                               AND    d.ACCOUNT_TYPE   = '''
                     || p_account_type
                     || '''';

        elsif p_report_type = 'GENERATED_REPORT' then
            l_sql := l_sql
                     || '   AND    ((A.STATUS  = ''GENERATED'') '
                     || '  OR      (A.STATUS NOT IN (''CANCELLED'',''DRAFT'',''VOID'')
                                 AND   B.STATUS = ''GENERATED''))';
        end if;

        l_file_name :=
            case
                when p_report_type = 'REVENUE_REPORT' then
                    'revenue_report_'
                    || p_account_type
                    || '_'
                    || to_char(sysdate, 'MMDDYYYY')
                    || '.csv'
                when p_report_type = 'VOID_REPORT' then
                    'void_report_'
                    || p_account_type
                    || '_'
                    || to_char(sysdate, 'MMDDYYYY')
                    || '.csv'
                when p_report_type = 'GENERATED_REPORT' then
                    'generated_report_'
                    || p_account_type
                    || '_'
                    || to_char(sysdate, 'MMDDYYYY')
                    || '.csv'
            end;

        l_rows := dump_csv(l_sql, ',', 'REPORT_DIR', l_file_name);
       -- IF l_rows > 0 THEN
        pc_notifications.insert_reports(
            case
                when p_report_type = 'REVENUE_REPORT' then
                    'Revenue Report '
                    || p_account_type
                    || '_'
                    || to_char(sysdate, 'MM/DD/YYYY')
                when p_report_type = 'VOID_REPORT' then
                    'Void Report '
                    || p_account_type
                    || '_'
                    || to_char(sysdate, 'MM/DD/YYYY')
                when p_report_type = 'GENERATED_REPORT' then
                    'Generated Report '
                    || p_account_type
                    || '_'
                    || to_char(sysdate, 'MM/DD/YYYY')
            end,
            '/u01/app/oracle/oradata/report/',
            l_file_name,
            'INVOICE_REPORTS',
            l_html_message);

      --  END IF;

        commit;
    exception
        when others then
            raise;
    end monthly_revenue_report;

    procedure schedule_invoice_report is
    begin
        if to_char(sysdate, 'DD') in ( '30', '01', '26', '02', '07' ) then
     -- monthly_ar_report('AR_REPORT','01-JAN-2014',SYSDATE-1);
            for x in (
                select
                    lookup_code
                from
                    account_type
            ) loop
                monthly_revenue_report(
                    trunc(sysdate - 1, 'MM'),
                    sysdate - 1,
                    x.lookup_code,
                    'VOID_REPORT'
                );

                monthly_revenue_report('01-JAN-2015', sysdate - 1, x.lookup_code, 'REVENUE_REPORT');
            end loop;
        end if;

        if to_char(sysdate, 'DD') in ( '01', '26', '30', '09', '02' ) then
            monthly_ar_report('AR_REPORT', '01-JAN-2014', sysdate - 1);
            monthly_revenue_report(null, null, null, 'GENERATED_REPORT');
        end if;

        null;
    end schedule_invoice_report;

    function get_unpaid_invoices (
        p_entrp_id     number default null,
        p_account_type varchar2 default null,
        p_acc_num      varchar2 default null,
        p_invoice_id   number default null,
        p_invoice_type varchar2 default null,
        p_invoice_date varchar2 default null,
        p_inv_date_to  varchar2 default null
    ) return unpaid_invoice_tbl
        pipelined
        deterministic
    is

        l_record unpaid_invoice_rec;
        q        varchar2(32767);
        w        varchar2(10000) := ' ';
        we       varchar2(1) := 'N';
        inv_cur  sys_refcursor;
    begin
        q := 'select      AR_INVOICE.INVOICE_NUMBER as INVOICE_NUMBER,
            AR_INVOICE.INVOICE_ID as INVOICE_ID,
            E.NAME EMPLOYER_NAME,
            TO_CHAR(AR_INVOICE.INVOICE_DATE,''MM/DD/YYYY'') as INVOICE_DATE,
            TO_CHAR(AR_INVOICE.BILLING_DATE,''MM/DD/YYYY'') as BILLING_DATE,
            TO_CHAR(AR_INVOICE.INVOICE_DUE_DATE,''MM/DD/YYYY'') as INVOICE_DUE_DATE,
            TO_CHAR(AR_INVOICE.INVOICE_POSTED_DATE,''MM/DD/YYYY'') as INVOICE_POSTED_DATE,
            TO_CHAR(AR_INVOICE.CANCELLED_DATE,''MM/DD/YYYY'') as CANCELLED_DATE,
             AR_INVOICE.INVOICE_TYPE as INVOICE_TYPE,
            FORMAT_MONEY(AR_INVOICE.INVOICE_AMOUNT) as INVOICE_AMOUNT,
            FORMAT_MONEY(AR_INVOICE.PAID_AMOUNT) as PAID_AMOUNT,
            FORMAT_MONEY(AR_INVOICE.PENDING_AMOUNT) as PENDING_AMOUNT,
            FORMAT_MONEY(AR_INVOICE.VOID_AMOUNT) as VOID_AMOUNT,
            AR_INVOICE.ENTITY_ID as ENTITY_ID,
            AR_INVOICE.ENTITY_TYPE as ENTITY_TYPE,
            AR_INVOICE.INVOICE_TERM as INVOICE_TERM,
            AR_INVOICE.PAYMENT_METHOD as PAYMENT_METHOD,
            AR_INVOICE.BATCH_NUMBER as BATCH_NUMBER,
            AR_INVOICE.COMMENTS as COMMENTS,
            AR_INVOICE.AUTO_PAY as AUTO_PAY,
            AR_INVOICE.ACC_NUM as ACC_NUM,
            AR_INVOICE.STATUS as STATUS,
            AR_INVOICE.INVOICE_REASON as INVOICE_REASON,
           ROUND(SYSDATE-INVOICE_DUE_DATE) as AGE_OF_INVOICE,
           AR_INVOICE.BILLING_NAME,
            AR_INVOICE.BILLING_ATTN,
            AR_INVOICE.BILLING_ADDRESS||'',''||AR_INVOICE.BILLING_CITY
        ||'',''||AR_INVOICE.BILLING_STATE
        ||'' ''||AR_INVOICE.BILLING_ZIP  BILLING_ADDRESS,
          (SELECT COUNT(DISTINCT PERS_ID) FROM INVOICE_DISTRIBUTION_SUMMARY IDS,ar_invoice_lines l
         WHERE IDS.INVOICE_ID = AR_INVOICE.INVOICE_ID
         and   l.invoice_id = ids.invoice_id
         and   l.status <> ''VOID'' and ids.invoice_line_id = l.invoice_line_id) NO_EMPLOYEES
         ,NULL NOTICE1, NULL NOTICE2, NULL FINAL_NOTICE, NULL URGENT_NOTICE -- Added by jaggi #11699
         ,NULL EMAILED_TO
         ,DECODE(AR_INVOICE.SENT_TO_COLLECTION,''N'',''No'',''Yes'') SENT_TO_COLLECTION
         ,AR_INVOICE.COLLECTION_SENT_ON
         ,PC_EMPLOYER_DIVISIONS.get_division_name(AR_INVOICE.DIVISION_CODE,E.ENTRP_ID) DIVISION_CODE
        ,PC_ACCOUNT.GET_BROKER(ACC.BROKER_ID)BROKER_NAME
 from    AR_INVOICE AR_INVOICE , ACCOUNT ACC,ENTERPRISE E
  WHERE 1 = 1
  AND     AR_INVOICE.ENTITY_ID = ACC.ENTRP_ID
  AND     ACC.ENTRP_ID = E.ENTRP_ID
  AND     AR_INVOICE.STATUS IN (''PROCESSED'',''PARTIALLY_POSTED'') ';
        if p_entrp_id is not null then
            w := w
                 || ' AND AR_INVOICE.ENTITY_ID = '
                 || p_entrp_id
                 || ' AND AR_INVOICE.ENTITY_TYPE = ''EMPLOYER'' ';
            we := 'Y';
        end if;

        if p_account_type is not null then
            w := w
                 || ' AND ACC.ACCOUNT_TYPE = '''
                 || p_account_type
                 || '''';
            we := 'Y';
        else
            w := w || ' AND ACC.ACCOUNT_TYPE IN (''HRA'',''FSA'') ';
            we := 'Y';
        end if;

        if p_acc_num is not null then
            w := w
                 || ' AND AR_INVOICE.ACC_NUM = '''
                 || p_acc_num
                 || '''';
            we := 'Y';
        end if;

        if p_invoice_id is not null then
            w := w
                 || ' AND AR_INVOICE.INVOICE_ID = '
                 || p_invoice_id;
            we := 'Y';
        end if;

        if
            p_invoice_date is not null
            and p_inv_date_to is null
        then
            w := w
                 || ' AND AR_INVOICE.INVOICE_DATE = TO_DATE('''
                 || p_invoice_date
                 || ''',''MM/DD/YYYY'')  ';
            we := 'Y';
        end if;

        if p_invoice_type is not null then
            w := w
                 || ' AND AR_INVOICE.INVOICE_REASON= '''
                 || p_invoice_type
                 || '''';
            we := 'Y';
        end if;

        if
            p_inv_date_to is not null
            and p_invoice_date is null
        then
            w := w
                 || ' AND AR_INVOICE.INVOICE_DATE = TO_DATE('''
                 || p_invoice_date
                 || ''',''MM/DD/YYYY'')  ';
            we := 'Y';
        end if;

        if
            p_inv_date_to is not null
            and p_invoice_date is not null
        then
            w := w
                 || ' AND AR_INVOICE.INVOICE_DATE >= TO_DATE('''
                 || p_invoice_date
                 || ''',''MM/DD/YYYY'')
            AND AR_INVOICE.INVOICE_DATE <= TO_DATE('''
                 || p_inv_date_to
                 || ''',''MM/DD/YYYY'') ';

            we := 'Y';
        end if;

        if we = 'Y' then
            q := q || w;
        end if;
        pc_log.log_error('GET_UNPAID_INVOICES', q);
        inv_cur := get_cursor(q);
        loop
            fetch inv_cur into l_record;
            exit when inv_cur%notfound;
            for x in (
                select
                    to_char(mailed_date, 'MM/DD/YYYY') mailed_date,
                    notification_type,
                    mailed_to
                from
                    ar_invoice_notifications
                where
                    invoice_id = l_record.invoice_id
            ) loop
                if x.notification_type = 'COURTESY_NOTICE1' then
                    l_record.ctsy_notice1_sent_on := x.mailed_date;
                    l_record.emailed_to := x.mailed_to;
                end if;

                if x.notification_type = 'COURTESY_NOTICE2' then
                    l_record.ctsy_notice2_sent_on := x.mailed_date;
                    l_record.emailed_to := x.mailed_to;
                end if;

                if x.notification_type = 'FINAL_NOTICE' then
                    l_record.final_notice_sent_on := x.mailed_date;
                    l_record.emailed_to := x.mailed_to;
                end if;
           -- Added by jaggi #11699 
                if x.notification_type = 'URGENT_NOTICE' then
                    l_record.urgent_notice_sent_on := x.mailed_date;
                    l_record.emailed_to := l_record.emailed_to
                                           || ','
                                           || x.mailed_to;
                end if;

            end loop;

            pipe row ( l_record );
        end loop;

    end get_unpaid_invoices;

    function get_unpaid_invoices_v2 (
        p_entrp_id     number default null,
        p_account_type varchar2 default null,
        p_acc_num      varchar2 default null,
        p_invoice_id   number default null,
        p_invoice_type varchar2 default null,
        p_invoice_date varchar2 default null,
        p_inv_date_to  varchar2 default null
    ) return unpaid_invoice_tbl
        pipelined
        deterministic
    is

        l_record unpaid_invoice_rec;
        q        varchar2(32767);
        w        varchar2(10000) := ' ';
        we       varchar2(1) := 'N';
        inv_cur  sys_refcursor;
    begin
        for x in (
            select
                ar_invoice.invoice_number                                                     as invoice_number,
                ar_invoice.invoice_id                                                         as invoice_id,
                e.name                                                                        employer_name,
                to_char(ar_invoice.invoice_date, 'MM/DD/YYYY')                                as invoice_date,
                to_char(ar_invoice.billing_date, 'MM/DD/YYYY')                                as billing_date,
                to_char(ar_invoice.invoice_due_date, 'MM/DD/YYYY')                            as invoice_due_date,
                to_char(ar_invoice.invoice_posted_date, 'MM/DD/YYYY')                         as invoice_posted_date,
                to_char(ar_invoice.cancelled_date, 'MM/DD/YYYY')                              as cancelled_date,
                ar_invoice.invoice_type                                                       as invoice_type,
                format_money(ar_invoice.invoice_amount)                                       as invoice_amount,
                format_money(ar_invoice.paid_amount)                                          as paid_amount,
                format_money(ar_invoice.pending_amount)                                       as pending_amount,
                format_money(ar_invoice.void_amount)                                          as void_amount,
                ar_invoice.entity_id                                                          as entity_id,
                ar_invoice.entity_type                                                        as entity_type,
                ar_invoice.invoice_term                                                       as invoice_term,
                ar_invoice.payment_method                                                     as payment_method,
                ar_invoice.batch_number                                                       as batch_number,
                ar_invoice.comments                                                           as comments,
                ar_invoice.auto_pay                                                           as auto_pay,
                ar_invoice.acc_num                                                            as acc_num,
                ar_invoice.status                                                             as status,
                ar_invoice.invoice_reason                                                     as invoice_reason,
                round(sysdate - invoice_due_date)                                             as age_of_invoice,
                ar_invoice.billing_name,
                ar_invoice.billing_attn,
                ar_invoice.billing_address
                || ','
                || ar_invoice.billing_city
                || ','
                || ar_invoice.billing_state
                || ' '
                || ar_invoice.billing_zip                                                     billing_address,
                (
                    select
                        count(distinct pers_id)
                    from
                        invoice_distribution_summary ids,
                        ar_invoice_lines             l
                    where
                            ids.invoice_id = ar_invoice.invoice_id
                        and l.invoice_id = ids.invoice_id
                        and l.status <> 'VOID'
                        and ids.invoice_line_id = l.invoice_line_id
                )                                                                             no_employees,
                null                                                                          notice1,
                null                                                                          notice2,
                null                                                                          final_notice,
                null                                                                          urgent_notice    -- Added by Jaggi #11699
                ,
                null                                                                          emailed_to,
                decode(ar_invoice.sent_to_collection, 'N', 'No', 'Yes')                       sent_to_collection,
                ar_invoice.collection_sent_on,
                pc_employer_divisions.get_division_name(ar_invoice.division_code, e.entrp_id) division_code,
                pc_account.get_broker(acc.broker_id)                                          broker_name
            from
                ar_invoice ar_invoice,
                account    acc,
                enterprise e
            where
                    1 = 1
                and ar_invoice.entity_id = acc.entrp_id
                and acc.entrp_id = e.entrp_id
                and ar_invoice.status in ( 'PROCESSED', 'PARTIALLY_POSTED' )
                and ar_invoice.invoice_date between nvl(to_date(p_invoice_date, 'MM/DD/YYYY'), ar_invoice.invoice_date) and nvl(to_date
                (p_inv_date_to, 'MM/DD/YYYY'), ar_invoice.invoice_date)
                and ar_invoice.entity_id = nvl(p_entrp_id, ar_invoice.entity_id)
                and ar_invoice.entity_type = 'EMPLOYER'
                and ( ( p_account_type is null
                        and acc.account_type in ( 'HRA', 'FSA' ) )
                      or acc.account_type = p_account_type )
                and ar_invoice.acc_num = nvl(p_acc_num, ar_invoice.acc_num)
                and ar_invoice.invoice_id = nvl(p_invoice_id, ar_invoice.invoice_id)
                and ar_invoice.invoice_reason = nvl(p_invoice_type, ar_invoice.invoice_reason)
        ) loop
            l_record.invoice_number := x.invoice_number;
            l_record.invoice_id := x.invoice_id;
            l_record.employer_name := x.employer_name;
            l_record.invoice_date := x.invoice_date;
            l_record.billing_date := x.billing_date;
            l_record.invoice_due_date := x.invoice_due_date;
            l_record.invoice_posted_date := x.invoice_posted_date;
            l_record.cancelled_date := x.cancelled_date;
            l_record.invoice_type := x.invoice_type;
            l_record.invoice_amount := x.invoice_amount;
            l_record.paid_amount := x.paid_amount;
            l_record.pending_amount := x.pending_amount;
            l_record.void_amount := x.void_amount;
            l_record.entity_id := x.entity_id;
            l_record.entity_type := x.entity_type;
            l_record.invoice_term := x.invoice_term;
            l_record.payment_method := x.payment_method;
            l_record.batch_number := x.batch_number;
            l_record.comments := x.comments;
            l_record.auto_pay := x.auto_pay;
            l_record.acc_num := x.acc_num;
            l_record.status := x.status;
            l_record.invoice_reason := x.invoice_reason;
            l_record.age_of_invoice := x.age_of_invoice;
            l_record.billing_name := x.billing_name;
            l_record.billing_attn := x.billing_attn;
            l_record.billing_address := x.billing_address;
            l_record.no_employees := x.no_employees;
            l_record.emailed_to := x.emailed_to;
            l_record.collection_sent_on := x.collection_sent_on;
            l_record.division_code := x.division_code;
            l_record.broker_name := x.broker_name;
            l_record.ctsy_notice1_sent_on := null;
            l_record.ctsy_notice2_sent_on := null;
            l_record.final_notice_sent_on := null;
            l_record.urgent_notice_sent_on := null;     -- Added by jaggi #11699
            l_record.emailed_to := null;
            for xx in (
                select
                    to_char(mailed_date, 'MM/DD/YYYY') mailed_date,
                    notification_type,
                    mailed_to
                from
                    ar_invoice_notifications
                where
                    invoice_id = l_record.invoice_id
            ) loop
                if xx.notification_type = 'COURTESY_NOTICE1' then
                    l_record.ctsy_notice1_sent_on := xx.mailed_date;
                    l_record.emailed_to := xx.mailed_to;
                end if;

                if xx.notification_type = 'COURTESY_NOTICE2' then
                    l_record.ctsy_notice2_sent_on := xx.mailed_date;
                    l_record.emailed_to := l_record.emailed_to
                                           || ','
                                           || xx.mailed_to;
                end if;

                if xx.notification_type = 'FINAL_NOTICE' then
                    l_record.final_notice_sent_on := xx.mailed_date;
                    l_record.emailed_to := l_record.emailed_to
                                           || ','
                                           || xx.mailed_to;
                end if;
          -- Added by jaggi #11699 
                if xx.notification_type = 'URGENT_NOTICE' then
                    l_record.urgent_notice_sent_on := xx.mailed_date;
                    l_record.emailed_to := l_record.emailed_to
                                           || ','
                                           || xx.mailed_to;
                end if;

            end loop;

            pipe row ( l_record );
        end loop;
    end get_unpaid_invoices_v2;

-- Added by Jaggi for 9830.
    function get_ga_monthly_stmt (
        p_ga_id        number,
        p_invoice_date varchar2 default null,
        p_inv_date_to  varchar2 default null,
        p_account_type varchar2 default null  -- Added by Joshi for 10744
    ) return ga_monthly_stmt_t
        pipelined
        deterministic
    is
        l_record_t ga_monthly_stmt_row_rec;
    begin
        for x in (
            select
                e.name    client_name,
                a.acc_num client_id,
                ar.invoice_id,
                ar.invoice_date,
                ar.start_date,
                ar.end_date,
                arl.description,
                arl.quantity,
                arl.no_of_months,
                arl.unit_rate_cost,
                arl.total_line_amount
            from
                ar_invoice         ar,
                ar_invoice_lines   arl,
                account            a,
                enterprise         e,
                invoice_parameters ip
            where
                    a.ga_id = p_ga_id
                and ar.invoice_id = arl.invoice_id
                and ar.entity_id = a.entrp_id
                and ar.entity_type = 'EMPLOYER'
                and ip.entity_id = a.entrp_id
                and ip.entity_type = 'EMPLOYER'
                and ar.rate_plan_id = ip.rate_plan_id
                and ip.status = 'A'
                and ip.invoice_type = 'FEE'
                and ar.approved_date is not null
                and a.entrp_id = e.entrp_id
                and ar.invoice_reason = 'FEE'
                and ar.status = 'PROCESSED' --9914
                   --AND ARL.STATUS <> 'VOID'
                and arl.status not in ( 'VOID', 'CANCELLED' )
                and ( ( p_account_type = 'HRAFSA'
                        and a.account_type in ( 'FSA', 'HRA' )
                        and arl.invoice_line_type <> 'FLAT_FEE' )
                      or ( p_account_type = a.account_type  -- AND IP.PAYMENT_METHOD = 'DIRECT_DEPOSIT' -- commented by 11061
                           and ip.invoice_frequency = 'MONTHLY' ) )
                and ar.invoice_date between nvl(to_date(p_invoice_date, 'MM/DD/YYYY'), ar.invoice_date) and nvl(to_date(p_inv_date_to
                , 'MM/DD/YYYY'), ar.invoice_date)
            order by
                a.acc_num,
                ar.invoice_id
        ) loop
            l_record_t.client_name := x.client_name;
            l_record_t.client_id := x.client_id;
            l_record_t.invoice_id := x.invoice_id;
            l_record_t.invoice_date := x.invoice_date;
            l_record_t.start_date := x.start_date;
            l_record_t.end_date := x.end_date;
            l_record_t.description := x.description;
            l_record_t.quantity := x.quantity;
            l_record_t.no_of_months := x.no_of_months;
            l_record_t.total_line_amount := x.total_line_amount;
            l_record_t.unit_rate_cost := x.unit_rate_cost;
            pipe row ( l_record_t );
        end loop;
    exception
        when others then
            null;
    end get_ga_monthly_stmt;

-- Added by Joshi for 10744.
    function geterisacobrapopfeeinvoicenotify return erisacobrapopfeeinvoicenotify_t
        pipelined
        deterministic
    is
        l_record                 erisacobrapopfeeinvoicenotify_rec;
        l_generate_combined_stmt varchar2(1) := 'N';
    begin
        for x in (
            select
                invoice_id,
                acc.acc_num acc_num,
                acc.account_type,
                acc.ga_id,
                null        invoice_frequency,
                null        payment_method
            from
                ar_invoice ar,
                account    acc
            where
                    ar.acc_id = acc.acc_id
                and acc.account_type not in ( 'HRA', 'FSA', 'COBRA' )
                and trunc(ar.approved_date) >= trunc(sysdate) - 1
                       -- AND AR.PAYMENT_METHOD = 'ACH_PUSH'  -- commented by Joshi.
                and mailed_date is null
                and ar.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
            union
            select
                invoice_id,
                acc.acc_num acc_num,
                acc.account_type,
                acc.ga_id,
                ip.invoice_frequency,
                ip.payment_method
            from
                ar_invoice         ar,
                account            acc,
                invoice_parameters ip
            where
                    ar.acc_id = acc.acc_id
                and ip.entity_id = acc.entrp_id
                and ip.entity_type = 'EMPLOYER'
                and ar.rate_plan_id = ip.rate_plan_id
                and ip.status = 'A'
                and ip.invoice_type = 'FEE'
                and acc.account_type = 'COBRA'
                and trunc(ar.approved_date) >= trunc(sysdate) - 1
                and mailed_date is null
                and ar.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
        ) loop
            if
                x.account_type = 'COBRA'
                and x.ga_id is not null
            then
                if (
                    x.invoice_frequency = 'MONTHLY'
                    and x.payment_method = 'DIRECT_DEPOSIT'
                ) then
                    select
                        generate_combined_stmt
                    into l_generate_combined_stmt
                    from
                        table ( pc_general_agent.get_ga_info(x.ga_id) );

                    if l_generate_combined_stmt = 'Y' then
                        l_record.invoice_id := null;
                    else
                        l_record.invoice_id := x.invoice_id;
                        l_record.acc_num := x.acc_num;
                    end if;

                else
                    l_record.invoice_id := x.invoice_id;
                    l_record.acc_num := x.acc_num;
                end if;
            else
                l_record.invoice_id := x.invoice_id;
                l_record.acc_num := x.acc_num;
            end if;

            if l_record.invoice_id is not null then
                pipe row ( l_record );
            end if;
        end loop;
    end geterisacobrapopfeeinvoicenotify;

end pc_invoice_reports;
/

