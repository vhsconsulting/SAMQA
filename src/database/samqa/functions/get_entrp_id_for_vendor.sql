create or replace function samqa.get_entrp_id_for_vendor (
    p_cobra_number in number,
    p_account_type in varchar2
) return number is
    l_entrp_id number;
begin
    for x in (
        select
            a.entrp_id,
            b.account_status,
            count(a.entrp_id)
            over(partition by cobra_id_number) er_cnt
        from
            enterprise a,
            account    b
        where
                cobra_id_number = p_cobra_number
            and a.entrp_id = b.entrp_id
            and b.account_type = p_account_type
    ) loop
        if x.er_cnt > 1 then
            if x.account_status = 1 then
                l_entrp_id := x.entrp_id;
            end if;
        else
            l_entrp_id := x.entrp_id;
        end if;
    end loop;

    return l_entrp_id;
exception
    when others then
        null;
end;
/


-- sqlcl_snapshot {"hash":"a7b6393a38cf4c8eaced340c6aab8aae1d05ae66","type":"FUNCTION","name":"GET_ENTRP_ID_FOR_VENDOR","schemaName":"SAMQA","sxml":""}