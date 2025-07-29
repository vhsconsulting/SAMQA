create or replace function samqa.get_qtly_date (
    p_sf_flg  in varchar2,
    p_in_date in date
) return number is
begin
  --Checking whether the SF Flag is 'Y' and Quarter date is occured
    if
        (
            nvl(p_sf_flg, 'N') = 'Y'
            and p_in_date is not null
        )
        and ( to_char(
            add_months(p_in_date, 3),
            'DDMM'
        ) = to_char(sysdate, 'DDMM')
        or to_char(
            add_months(p_in_date, 6),
            'DDMM'
        ) = to_char(sysdate, 'DDMM')
        or to_char(
            add_months(p_in_date, 9),
            'DDMM'
        ) = to_char(sysdate, 'DDMM')
        or to_char(
            add_months(p_in_date, 12),
            'DDMM'
        ) = to_char(sysdate, 'DDMM') )
    then
        return 1;
    else
        return 0;
    end if;
end;
/


-- sqlcl_snapshot {"hash":"14bc0e0144f9420634da7d237e3d0f6318b0bc85","type":"FUNCTION","name":"GET_QTLY_DATE","schemaName":"SAMQA","sxml":""}