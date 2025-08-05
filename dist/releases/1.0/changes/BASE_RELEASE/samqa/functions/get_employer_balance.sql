-- liquibase formatted sql
-- changeset SAMQA:1754373927369 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_employer_balance.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_employer_balance.sql:null:737990ea9f3235522eae419d983c55fd51f58459:create

create or replace function samqa.get_employer_balance (
    p_entrp_id  in number,
    p_end_date  in date,
    p_plan_type in varchar2
) return number is
    l_amount number := 0;
begin
    for x in (
        select
            sum(check_amount) check_amount
        from
            employer_balances_v
        where
                entrp_id = p_entrp_id
            and ( ( p_plan_type = 'HRA'
                    and plan_type in ( 'HRA', 'HRP', 'ACO', 'HR4', 'HR5' ) )
                  or ( p_plan_type = 'FSA'
                       and plan_type in ( 'FSA', 'DCA', 'TRN', 'PKG', 'IIR',
                                          'LPF' ) ) )
            and transaction_date <= p_end_date
    ) loop
        l_amount := x.check_amount;
    end loop;

    return l_amount;
end get_employer_balance;
/

