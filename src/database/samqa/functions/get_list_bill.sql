create or replace function samqa.get_list_bill (
    p_list_bill varchar2
) return varchar2 is
    l_return varchar2(1);
begin
    for x in (
        select
            to_char(check_date, 'MM/DD/YYYY') check_date,
            check_number,
            check_amount,
            remaining_balance,
            entrp_id
        from
            employer_deposits
        where
            list_bill = p_list_bill
    ) loop
        return x.check_date
               || ' '
               || x.check_number
               || ' '
               || x.check_amount
               || ' '
               || to_char(x.remaining_balance, 'FML999G999G999G999G990');
    end loop;
end;
/


-- sqlcl_snapshot {"hash":"7cd28fd509ec79b1d1f9dda23706d599bf177830","type":"FUNCTION","name":"GET_LIST_BILL","schemaName":"SAMQA","sxml":""}