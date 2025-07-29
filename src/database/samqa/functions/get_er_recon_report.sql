create or replace function samqa.get_er_recon_report return pc_employer_fin.report_rcon_t
    pipelined
    deterministic
is

    l_record     pc_employer_fin.report_rcon_rec;
    v_record     fsahra_er_balance_gtt%rowtype;
    type v_tbl is
        table of v_record%type index by binary_integer;
    l_tbl        v_tbl;
    l_balance    number := 0;
    l_ord        number := 0;
    cursor v_cursor is
    select
        *
    from
        fsahra_er_balance_gtt
    order by
        paid_date asc,
        ord_no asc;

    p_limit_size number := 10000;
begin
    open v_cursor;
    loop
        fetch v_cursor
        bulk collect into l_tbl limit p_limit_size;
        exit when l_tbl.count = 0;
        for i in 1..l_tbl.count loop
            l_balance := l_balance + l_tbl(i).check_amount;
            l_ord := l_ord + 1;
            l_record.transaction_type := l_tbl(i).transaction_type;
            l_record.acc_num := l_tbl(i).acc_num;
            l_record.claim_invoice_id := l_tbl(i).claim_invoice_id;
            l_record.plan_type := l_tbl(i).plan_type;
            l_record.transaction_date := to_char(l_tbl(i).transaction_date,
                                                 'MM/DD/YYYY');
            l_record.paid_date := to_char(l_tbl(i).paid_date,
                                          'MM/DD/YYYY');
        --     L_RECORD.TRANSACTION_DATE :=l_tbl(i).TRANSACTION_DATE;
        --     L_RECORD.PAID_DATE := l_tbl(i).PAID_DATE;
            l_record.check_amount := l_tbl(i).check_amount;
            l_record.note := l_tbl(i).note;
            l_record.reason_code := l_tbl(i).reason_code;
            l_record.employer_payment_id := l_tbl(i).employer_payment_id;
            l_record.first_name := nvl(l_tbl(i).first_name,
                                       '');
            l_record.last_name := nvl(l_tbl(i).last_name,
                                      '');
            l_record.balance := l_balance;
            l_record.ord_no := l_ord;
            pipe row ( l_record );
        end loop;

    end loop;

    close v_cursor;
    return;
end;
/


-- sqlcl_snapshot {"hash":"c787ff595daf4676af2b51044515a32a197c1378","type":"FUNCTION","name":"GET_ER_RECON_REPORT","schemaName":"SAMQA","sxml":""}