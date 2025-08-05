-- liquibase formatted sql
-- changeset SAMQA:1754374172571 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\employer_marketing_analytics_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/employer_marketing_analytics_v.sql:null:ddf9a5fa1830ad666714413c9c439bbac3e7aab2:create

create or replace force editionable view samqa.employer_marketing_analytics_v (
    entrp_id,
    name,
    address,
    city,
    state,
    zip,
    email,
    user_type,
    plan_type
) as
    select distinct
        c.entrp_id,
        '"'
        || b.name
        || '"'                                                            name,
        '"'
        || b.address
        || '"'                                                            address,
        '"'
        || b.city
        || '"'                                                            city,
        '"'
        || b.state
        || '"'                                                            state,
        '"'
        || b.zip
        || '"'                                                            zip,
        ou.email,
        decode(ou.emp_reg_type, 1, 'Enrollment Account', 'Employer User') user_type,
        bp.plan_type
    from
        enterprise                b,
        account                   c,
        ben_plan_enrollment_setup bp,
        online_users              ou
    where
            b.entrp_id = c.entrp_id
        and c.acc_id = bp.acc_id
        and b.entrp_code = ou.tax_id
        and c.account_type in ( 'HRA', 'FSA', 'CMP' )
    union
    select distinct
        c.entrp_id,
        '"'
        || b.name
        || '"'                                                            name,
        '"'
        || b.address
        || '"'                                                            address,
        '"'
        || b.city
        || '"'                                                            city,
        '"'
        || b.state
        || '"'                                                            state,
        '"'
        || b.zip
        || '"'                                                            zip,
        ou.email,
        decode(ou.emp_reg_type, 1, 'Enrollment Account', 'Employer User') user_type,
        c.account_type
    from
        enterprise   b,
        account      c,
        online_users ou
    where
            b.entrp_id = c.entrp_id
        and b.entrp_code = ou.tax_id
        and c.account_type not in ( 'HRA', 'FSA', 'CMP' );

