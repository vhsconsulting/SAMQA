-- liquibase formatted sql
-- changeset SAMQA:1754373927386 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_entrp_id_for_vendor.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_entrp_id_for_vendor.sql:null:a7b6393a38cf4c8eaced340c6aab8aae1d05ae66:create

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

