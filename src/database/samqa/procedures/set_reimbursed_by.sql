create or replace procedure samqa.set_reimbursed_by (
    p_ben_plan_id          in number,
    p_claim_reimbursed_by  in varchar2,
    p_funding_options      in varchar2,
    p_user_id              in number default 0,
    p_reimburse_start_date in date
) is
begin
    if p_ben_plan_id is not null then
        for x in (
            select
                ben_plan_id,
                ben_plan_id_main,
                product_type,
                case
                    when product_type = 'FSA' then
                        (
                            select
                                lookup_code
                            from
                                lookups
                            where
                                    lookup_name = 'FSA_FUNDING_OPTION'
                                and lookup_code = p_funding_options
                        )
                    else
                        (
                            select
                                lookup_code
                            from
                                lookups
                            where
                                    lookup_name = 'HRA_FUNDING_OPTION'
                                and lookup_code = p_funding_options
                        )
                end funding_options
            from
                ben_plan_enrollment_setup
            where
                ben_plan_id = p_ben_plan_id
        ) loop
            if x.ben_plan_id_main is not null then
                raise_application_error('-20001', 'Not an employer benefit plan');
            else
                if
                    x.funding_options is null
                    and p_funding_options is not null
                then
                    raise_application_error('-20001', 'Not a valid funding option');
                else
                    update ben_plan_enrollment_setup
                    set
                        claim_reimbursed_by = nvl(p_claim_reimbursed_by, claim_reimbursed_by),
                        funding_options = nvl(p_funding_options, funding_options),
                        reimburse_start_date = nvl(p_reimburse_start_date, reimburse_start_date)
                    where
                        ben_plan_id = p_ben_plan_id;

                -- Below Update is added by Swamy for Ticket#7512, when the Employer's Claim_reimbursed_by is changed,then Employee's Claim_reimbursed_by should also be changed as per the value of Employer.
                    update ben_plan_enrollment_setup
                    set
                        claim_reimbursed_by = nvl(p_claim_reimbursed_by, claim_reimbursed_by),
                        funding_options = nvl(p_funding_options, funding_options),
                        reimburse_start_date = nvl(p_reimburse_start_date, reimburse_start_date)
                    where
                        ben_plan_id_main = p_ben_plan_id;

                end if;
            end if;
        end loop;

    end if;
end set_reimbursed_by;
/


-- sqlcl_snapshot {"hash":"e00709fd61a90099d4ddd7113be9598cb394cc1f","type":"PROCEDURE","name":"SET_REIMBURSED_BY","schemaName":"SAMQA","sxml":""}