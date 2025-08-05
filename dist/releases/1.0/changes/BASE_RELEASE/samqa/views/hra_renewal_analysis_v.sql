-- liquibase formatted sql
-- changeset SAMQA:1754374175540 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\hra_renewal_analysis_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/hra_renewal_analysis_v.sql:null:edc96dda09723d29c79ec8992235090aac9aedcf:create

create or replace force editionable view samqa.hra_renewal_analysis_v (
    employer_name,
    last_active_plan,
    no_of_plan_years,
    last_renewed_employees,
    prev_renewed_employees
) as
    select
        pc_entrp.get_entrp_name(entrp_id) employer_name,
        max(plan_start_date)              last_active_plan,
        count(distinct plan_start_date)   no_of_plan_years,
        case
            when count(distinct renewed) = 1 then
                0
            else
                count(distinct renewed) - 1
        end                               last_renewed_employees,
        case
            when count(distinct nonrenewed) = 1 then
                0
            else
                count(distinct nonrenewed) - 1
        end                               prev_renewed_employees
    from
        (
            select
                d.entrp_id,
                b.acc_id,
                case
                    when b.plan_end_date > sysdate then
                        b.acc_id
                    else
                        0
                end renewed,
                case
                    when c.plan_end_date < sysdate then
                        c.acc_id
                    else
                        0
                end nonrenewed,
                b.plan_start_date
            from
                ben_plan_enrollment_setup b,
                ben_plan_enrollment_setup c,
                account                   a,
                person                    d
            where
                    a.acc_id = b.acc_id
                and a.pers_id = d.pers_id
                and c.acc_id = b.acc_id
                and c.product_type = 'HRA'
--  AND D.ENTRP_ID =  11523
                and b.entrp_id is null
                and a.entrp_id is null
                and b.status <> 'R'
                and c.status <> 'R'
                and c.plan_type = b.plan_type
 -- AND B.PLAN_START_DATE > C.PLAN_START_DATE 
                and d.entrp_id is not null
        )
    group by
        entrp_id;

