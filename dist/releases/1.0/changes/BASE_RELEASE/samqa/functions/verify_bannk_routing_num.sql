-- liquibase formatted sql
-- changeset SAMQA:1754373928713 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\verify_bannk_routing_num.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/verify_bannk_routing_num.sql:null:79a9b7a8429fac57b5aa035caf704154ec72e0b6:create

create or replace function samqa.verify_bannk_routing_num (
    p_bank_routing_num in varchar2
) return varchar2 as

    l_bank_routing_num_len integer;
    l_return               varchar2(1) := 'N';
    n                      integer := 0;
    l_third_sum            integer := 0;
    l_second_sum           integer := 0;
    l_first_sum            integer := 0;
    l_total_sum            integer := 0;
begin
    if
        is_number(p_bank_routing_num) = 'Y'
        and length(p_bank_routing_num) = 9
    then
        l_first_sum := 3 * ( to_number ( substr(p_bank_routing_num, 1, 1) ) + to_number ( substr(p_bank_routing_num, 4, 1) ) + to_number
        ( substr(p_bank_routing_num, 7, 1) ) );

        dbms_output.put_line('l_first_sum: ' || l_first_sum);
        l_second_sum := 7 * ( to_number ( substr(p_bank_routing_num, 2, 1) ) + to_number ( substr(p_bank_routing_num, 5, 1) ) + to_number
        ( substr(p_bank_routing_num, 8, 1) ) );

        dbms_output.put_line('l_second_sum: ' || l_second_sum);
        l_third_sum := to_number ( substr(p_bank_routing_num, 3, 1) ) + to_number ( substr(p_bank_routing_num, 6, 1) ) + to_number ( substr
        (p_bank_routing_num, 9, 1) );

        dbms_output.put_line('l_third_sum: ' || l_third_sum);
        -- If the resulting sum is an even multiple of ten (but not zero),
        -- the aba routing number is good.
        l_total_sum := l_first_sum + l_second_sum + l_third_sum;
        if
            l_total_sum > 0
            and mod(l_total_sum, 10) = 0
        then
            return 'Y';
        else
            return 'N';
        end if;

    else
        return 'N';
    end if;
exception
    when others then
        return 'N';
end verify_bannk_routing_num;
/

