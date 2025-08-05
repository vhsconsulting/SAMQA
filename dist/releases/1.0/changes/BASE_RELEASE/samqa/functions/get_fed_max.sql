-- liquibase formatted sql
-- changeset SAMQA:1754373927670 stripComments:false logicalFilePath:BASE_RELEASE\samqa\functions\get_fed_max.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/functions/get_fed_max.sql:null:3ee4199bd498f10195a8c84e194a8f62823e2baf:create

create or replace function samqa.get_fed_max (
    p_plan_type  in number,
    p_birth_date in date,
    p_year       in number
) return number is
    l_fed_max number := 7450;
begin
    select
            case
                when p_plan_type = 0 then
                    pc_param.get_system_value('INDIVIDUAL_CONTRIBUTION', to_date('01/01/'
                                                                                 || p_year, 'MM/DD/YYYY'))
                else
                    pc_param.get_system_value('FAMILY_CONTRIBUTION', to_date('01/01/'
                                                                             || p_year, 'MM/DD/YYYY'))
            end
            +
            case
                when trunc(months_between(sysdate, p_birth_date) / 12) >= 55 then
                    to_number(pc_param.get_system_value('CATCHUP_CONTRIBUTION', to_date('01/01/'
                                                                                        || p_year, 'MM/DD/YYYY')))
                else
                    0
            end
    into l_fed_max
    from
        dual;

    return l_fed_max;
end get_fed_max;
/

