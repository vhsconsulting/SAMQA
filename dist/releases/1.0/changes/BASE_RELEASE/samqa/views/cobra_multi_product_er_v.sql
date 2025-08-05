-- liquibase formatted sql
-- changeset SAMQA:1754374170872 stripComments:false logicalFilePath:BASE_RELEASE\samqa\views\cobra_multi_product_er_v.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/views/cobra_multi_product_er_v.sql:null:43cc63d61fa6624c5d42881b29571b4344fe2305:create

create or replace force editionable view samqa.cobra_multi_product_er_v (
    name,
    entrp_code,
    acc_num,
    start_date,
    creation_date,
    entrp_id,
    acc_id
) as
    select distinct
        a.name,
        replace(a.entrp_code, '-') entrp_code,
        b.acc_num,
        b.start_date,
        b.creation_date,
        a.entrp_id,
        b.acc_id
    from
        enterprise a,
        account    b,
        enterprise c,
        account    d
    where
            a.entrp_id = b.entrp_id
        and b.account_type = 'COBRA'
        and replace(a.entrp_code, '-') = replace(c.entrp_code, '-')
        and c.entrp_id = d.entrp_id
        and d.account_type in ( 'HRA', 'FSA', 'HSA' );

