create or replace function samqa.get_balance (
    acc_id_in  in number,
    begin_date in date default '01-JAN-2004',
    end_date   in date default sysdate
) return number is
    l_balance number := 0;
begin

    -- F = Fee income from fee bucket
    -- FP = Fee Payment from fee bucket
    -- E  = Pending eDeposit
    -- C  = Card Transfer

    for x in (
        select
            sum(amount) bal
        from
            balance_register
        where
            reason_mode not in ( 'F', 'E', 'C', 'FP', 'EP' )
            and acc_id = acc_id_in
            and txn_date between trunc(begin_date) and trunc(end_date)
        group by
            acc_id
    ) loop
        l_balance := x.bal;
    end loop;

    return l_balance;
end;
/


-- sqlcl_snapshot {"hash":"c7804a94fb9d694ef3158ce84891721d2f58aedf","type":"FUNCTION","name":"GET_BALANCE","schemaName":"SAMQA","sxml":""}