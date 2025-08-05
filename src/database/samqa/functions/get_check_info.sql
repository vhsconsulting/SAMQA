create or replace function samqa.get_check_info (
    p_acc_id       in number,
    p_orig_sys_ref in number
) return number is
    l_flag number := null;
begin
    for x in (
        select
            acc_id,
            entrp_id
        from
            account
        where
            acc_id = p_acc_id
    ) loop
        if x.entrp_id is null then
            select
                sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0)) check_amount
            into l_flag
            from
                income  a,
                account b,
                person  c
            where
                    b.acc_id = p_acc_id
                and a.change_num = p_orig_sys_ref
                and a.acc_id = b.acc_id
                and b.pers_id = c.pers_id;

        else
            select
                sum(nvl(amount, 0) + nvl(amount_add, 0) + nvl(er_fee_amount, 0) + nvl(ee_fee_amount, 0))
            into l_flag
            from
                employer_deposits a,
                income            b
            where
                    a.entrp_id = x.entrp_id
                and a.employer_deposit_id = p_orig_sys_ref
                and a.entrp_id = b.contributor
                and a.list_bill = b.list_bill;

        end if;
    end loop;

    return l_flag;
exception
    when others then
        l_flag := null;
        return l_flag;
end;
/


-- sqlcl_snapshot {"hash":"5656b9075cbc59ff225ee65d61b547288a025fef","type":"FUNCTION","name":"GET_CHECK_INFO","schemaName":"SAMQA","sxml":""}