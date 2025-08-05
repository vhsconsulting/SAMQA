create or replace function samqa.get_tax_day return date is
    l_date date := to_date ( '15-APR-2011' );
begin
    for x in (
        select
            to_date(param_value) tax_date
        from
            system_parameters
        where
                param_code = 'TAX_DAY'
            and trunc(effective_date) >= trunc(sysdate, 'YYYY')
            and trunc(effective_date) <= to_date(param_value)
            and to_date(param_value) <= add_months(
                trunc(sysdate, 'YYYY'),
                12
            )
        union
        select
            to_date(param_value) tax_date
        from
            system_parameters
        where
                param_code = 'TAX_DAY'
            and trunc(effective_date) >= trunc(sysdate + 1, 'YYYY')
            and trunc(effective_date) <= to_date(param_value)
            and to_char(sysdate + 1, 'YYYY') <> to_char(sysdate, 'YYYY')
    ) loop
        l_date := x.tax_date;
    end loop;

    return l_date;
end get_tax_day;
/


-- sqlcl_snapshot {"hash":"61479da5cff15224271a9874beb047ca2e81ab52","type":"FUNCTION","name":"GET_TAX_DAY","schemaName":"SAMQA","sxml":""}