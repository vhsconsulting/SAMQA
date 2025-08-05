create materialized view samqa.broker_account_nohsa_rev_mv (
    acc_id,
    account_type,
    broker_id,
    salesrep_id,
    broker,
    monthly_discount,
    setup_discount,
    setup,
    setup_optional,
    monthly,
    revenue_amount,
    pay_approved_date,
    start_date,
    city,
    state,
    zip,
    salesrep_name
) build immediate using index
    refresh force
    on demand
    using enforced constraints
    disable on query computation
    disable query rewrite
as
    select
        q.acc_id,
        q.account_type,
        q.broker_id,
        nvl(q.salesrep_id, 0) salesrep_id,
        q.broker,
        q.monthly_discount,
        q.setup_discount,
        q.setup,
        q.setup_optional,
        q.monthly,
        q.revenue_amount,
        q.pay_approved_date,
        q.start_date,
        q.city,
        q.state,
        q.zip,
        s.name                as salesrep_name
    from
        (
            select
                i.acc_id,
                a.account_type,
                a.broker_id, 
    /*case when i.salesrep_id is not null and i.salesrep_id != 0 then i.salesrep_id
        else case when a.salesrep_id is not null and a.salesrep_id != 0 then a.salesrep_id
            else bk.salesrep_id  end
            end */
                bk.salesrep_id  as salesrep_id,
                replace(
                    trim(pers.first_name
                         || ' '
                         || pers.last_name),
                    '  ',
                    ' '
                )               as broker,
                case
                    when a.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                             'ACA', 'FSA', 'HRA', 'RB', 'FMLA' )
                         and il.rate_code = 89
                         and exists (
                        select
                            *
                        from
                            ar_invoice_lines
                        where
                                invoice_id = il.invoice_id
                            and rate_code in ( 183, 184 )
                    ) then
                        il.total_line_amount
                    else
                        0
                end             monthly_discount,
                case
                    when a.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                             'ACA', 'FSA', 'HRA', 'RB', 'FMLA' )
                         and il.rate_code = 264
                         or ( il.rate_code in ( 89, 266 )
                              and exists (
                        select
                            *
                        from
                            ar_invoice_lines
                        where
                                invoice_id = il.invoice_id
                            and rate_code in ( 1, 100, 43, 44 )
                    ) ) then
                        il.total_line_amount
                    else
                        0
                end             setup_discount,
                case
                    when a.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                             'ACA', 'FSA', 'HRA', 'RB', 'FMLA' )
                         and p.reason_code in ( 1, 100, 43, 44 ) then
                        il.total_line_amount
                    else
                        0
                end             setup,
                case
                    when a.account_type = 'COBRA'
                         and il.rate_code in ( 54, 55, 86 )
                         and exists (
                        select
                            *
                        from
                            ar_invoice_lines
                        where
                                invoice_id = il.invoice_id
                            and rate_code in ( 1, 100, 43, 44, 184 )
                    ) then
                        il.total_line_amount
                    else
                        0
                end             setup_optional,
                (
                    case
                        when p.reason_code = 184 then
                            il.total_line_amount
                        when a.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                 'ACA', 'FSA', 'HRA', 'RB' )
                             and p.reason_code in ( 2, 35, 31, 33, 67,
                                                    34, 68, 36, 39, 38,
                                                    37, 32, 40 )
                             and ( greatest(
                            trunc(a.reg_date),
                            trunc(a.start_date)
                        ) >= add_months(
                            trunc(i.start_date),
                            -11
                        ) ) then
                            il.total_line_amount
                        when a.account_type = 'FMLA'
                             and p.reason_code = 2
                             and ( greatest(
                            trunc(a.reg_date),
                            trunc(a.start_date)
                        ) >= add_months(
                            trunc(i.start_date),
                            -11
                        ) ) then
                            il.total_line_amount
                        else
                            0
                    end
                )               monthly,
                case
                    when il.rate_code = 264
                         or ( il.rate_code in ( 89, 266 )
                              and exists (
                            select
                                *
                            from
                                ar_invoice_lines
                            where
                                    invoice_id = il.invoice_id
                                and rate_code in ( 1, 100, 43, 44, 184 )
                        ) ) then
                            il.total_line_amount
                    else
                        0
                end
                +
                case
                    when a.account_type = 'COBRA'
                         and il.rate_code in ( 54, 55, 86 )
                         and exists (
                            select
                                *
                            from
                                ar_invoice_lines
                            where
                                    invoice_id = il.invoice_id
                                and rate_code in ( 1, 100, 43, 44, 184 )
                        ) then
                            il.total_line_amount
                    else
                        0
                end
                +
                case
                    when p.reason_code in ( 1, 100, 43, 44 ) then
                            il.total_line_amount
                    else
                        0
                end
                + (
                    case
                        when p.reason_code = 184 then
                            il.total_line_amount
                        when a.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                                 'ACA', 'FSA', 'HRA', 'RB' )
                             and p.reason_code in ( 2, 35, 31, 33, 67,
                                                    34, 68, 36, 39, 38,
                                                    37, 32, 40 )
                             and ( greatest(
                            trunc(a.reg_date),
                            trunc(a.start_date)
                        ) >= add_months(
                            trunc(i.start_date),
                            -11
                        ) ) then
                            il.total_line_amount
                        when a.account_type = 'FMLA'
                             and p.reason_code = 2
                             and ( greatest(
                            trunc(a.reg_date),
                            trunc(a.start_date)
                        ) >= add_months(
                            trunc(i.start_date),
                            -11
                        ) ) then
                            il.total_line_amount
                        else
                            0
                    end
                )               as revenue_amount,
                i.approved_date as pay_approved_date,
                i.start_date,
                pers.city,
                pers.state,
                pers.zip
            from
                ar_invoice       i,
                ar_invoice_lines il,
                pay_reason       p,
                account          a,
                person           pers,
                broker           bk
            where
                    i.invoice_id = il.invoice_id
                and i.acc_id = a.acc_id
                and a.account_type in ( 'COBRA', 'ERISA_WRAP', 'POP', 'CMP', 'FORM_5500',
                                        'FSA', 'HRA', 'ACA', 'RB', 'FMLA' )
                and i.invoice_reason = 'FEE'
                and ( i.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED' )
                      and il.status in ( 'POSTED', 'PARTIALLY_POSTED', 'PROCESSED', 'ADJUSTMENT' ) )
                and il.rate_code = to_char(p.reason_code)
                and a.broker_id = pers.pers_id (+)
                and a.broker_id = bk.broker_id
        )        q,
        salesrep s
    where
        q.salesrep_id = s.salesrep_id (+);


-- sqlcl_snapshot {"hash":"35e4a2b8933ecc95f7d2e6fbffd48252b3c0ea2a","type":"MATERIALIZED_VIEW","name":"BROKER_ACCOUNT_NOHSA_REV_MV","schemaName":"SAMQA","sxml":"\n  <MATERIALIZED_VIEW xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BROKER_ACCOUNT_NOHSA_REV_MV</NAME>\n   <COL_LIST>\n      <COL_LIST_ITEM>\n         <NAME>ACC_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ACCOUNT_TYPE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>BROKER_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SALESREP_ID</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>BROKER</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>MONTHLY_DISCOUNT</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SETUP_DISCOUNT</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SETUP</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SETUP_OPTIONAL</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>MONTHLY</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>REVENUE_AMOUNT</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>PAY_APPROVED_DATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>START_DATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>CITY</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>STATE</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>ZIP</NAME>\n      </COL_LIST_ITEM>\n      <COL_LIST_ITEM>\n         <NAME>SALESREP_NAME</NAME>\n      </COL_LIST_ITEM>\n   </COL_LIST>\n   <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n   <PHYSICAL_PROPERTIES>\n      <HEAP_TABLE></HEAP_TABLE>\n   </PHYSICAL_PROPERTIES>\n   <BUILD>IMMEDIATE</BUILD>\n   <REFRESH>\n      <LOCAL_ROLLBACK_SEGMENT>\n         <DEFAULT></DEFAULT>\n      </LOCAL_ROLLBACK_SEGMENT>\n      <CONSTRAINTS>ENFORCED</CONSTRAINTS>\n   </REFRESH>\n   \n</MATERIALIZED_VIEW>"}